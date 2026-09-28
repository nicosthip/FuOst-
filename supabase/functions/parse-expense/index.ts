import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Manejar preflight request (CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { text, userId } = await req.json()

    if (!text || !userId) {
      return new Response(JSON.stringify({ error: "Missing text or userId" }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // Usaremos Gemini 1.5 Flash (Gratuito a través de Google AI Studio)
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    
    // Si no hay API Key de IA configurada, usamos un sistema básico de respaldo (Regex)
    if (!geminiApiKey) {
      console.log("No Gemini API key found, using fallback regex parser.");
      return handleFallbackParsing(text, userId);
    }

    // Configurar cliente de base de datos para obtener las categorías
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Obtener las categorías del usuario para que la IA sepa dónde clasificarlo
    const { data: categories } = await supabase
      .from('categories')
      .select('id, name')
      .or(`user_id.eq.${userId},user_id.is.null`)

    const categoryNames = categories?.map(c => c.name).join(', ') || "Comida, Transporte, Hogar, Entretenimiento, Salud, Otros"

    // Llamar a Gemini API
    const prompt = `
      Eres un asistente financiero. Extrae la información de este gasto: "${text}".
      Categorías disponibles: ${categoryNames}.
      Devuelve SOLO un objeto JSON válido con esta estructura exacta, sin markdown ni explicaciones:
      {
        "amount": (número decimal, obligatorio),
        "category_name": (string, elige la más cercana de la lista, obligatorio),
        "note": (string, resumen de 1 a 3 palabras)
      }
    `

    const geminiRes = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.1 } // Baja temperatura para mayor precisión
      })
    });

    const geminiData = await geminiRes.json();
    
    if (!geminiRes.ok) {
        throw new Error(geminiData.error?.message || "Error from Gemini API");
    }

    // Extraer y limpiar el JSON
    const responseText = geminiData.candidates[0].content.parts[0].text;
    const cleanJsonString = responseText.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsedData = JSON.parse(cleanJsonString);

    // Buscar el ID de la categoría sugerida
    const matchedCategory = categories?.find(c => c.name.toLowerCase() === parsedData.category_name.toLowerCase());
    const finalCategoryId = matchedCategory ? matchedCategory.id : null;

    // Guardar el gasto en la base de datos
    const { data: insertedExpense, error: insertError } = await supabase
      .from('expenses')
      .insert({
        user_id: userId,
        amount: parsedData.amount,
        category_id: finalCategoryId,
        note: parsedData.note,
        origin: 'message',
        date: new Date().toISOString()
      })
      .select()
      .single()

    if (insertError) throw insertError;

    return new Response(JSON.stringify({ success: true, data: insertedExpense }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error("Error processing request:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

// Sistema de respaldo (Fallback) si no hay IA configurada
async function handleFallbackParsing(text: string, userId: string) {
  // Regex básico para detectar números (ej: "15" o "15.50")
  const amountMatch = text.match(/\d+(\.\d{1,2})?/);
  if (!amountMatch) {
    return new Response(JSON.stringify({ error: "No pude entender el monto. Intenta escribir 'Gasté 20 en tacos'." }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
  
  const amount = parseFloat(amountMatch[0]);
  
  // Solo devolvemos la respuesta parseada para que el Frontend la guarde
  return new Response(JSON.stringify({ 
    success: true, 
    fallback: true,
    data: {
      amount: amount,
      category_name: "Otros",
      note: text.substring(0, 20) + "..."
    }
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 200,
  });
}
