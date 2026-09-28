-- Activar la extensión UUID si no está habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear tipo de origen del gasto
CREATE TYPE expense_origin AS ENUM ('wallet', 'manual', 'message');

-- Tabla de Categorías
CREATE TABLE categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- null significa que es una categoría por defecto del sistema
    name TEXT NOT NULL,
    icon TEXT NOT NULL, -- Nombre de un SF Symbol de Apple (ej: 'car.fill')
    color TEXT NOT NULL, -- Código Hexadecimal
    is_custom BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Tabla de Gastos
CREATE TABLE expenses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    note TEXT,
    origin expense_origin DEFAULT 'manual',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Configuración de Seguridad (Row Level Security - RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Políticas para Categorías:
-- 1. Todos los usuarios pueden ver las categorías por defecto (user_id is null) o las suyas propias.
CREATE POLICY "Users can view default or own categories" ON categories
    FOR SELECT USING (user_id IS NULL OR user_id = auth.uid());

-- 2. Los usuarios pueden crear sus propias categorías
CREATE POLICY "Users can insert custom categories" ON categories
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. Los usuarios pueden editar sus propias categorías
CREATE POLICY "Users can update custom categories" ON categories
    FOR UPDATE USING (auth.uid() = user_id);

-- 4. Los usuarios pueden borrar sus propias categorías
CREATE POLICY "Users can delete custom categories" ON categories
    FOR DELETE USING (auth.uid() = user_id);

-- Políticas para Gastos (CRUD completo pero solo para el dueño):
CREATE POLICY "Users can view own expenses" ON expenses
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own expenses" ON expenses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own expenses" ON expenses
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own expenses" ON expenses
    FOR DELETE USING (auth.uid() = user_id);

-- Insertar Categorías por Defecto Sugeridas
INSERT INTO categories (name, icon, color, is_custom) VALUES 
('Comida', 'fork.knife', '#FF9F0A', false),
('Transporte', 'car.fill', '#0A84FF', false),
('Hogar', 'house.fill', '#32ADE6', false),
('Entretenimiento', 'tv.fill', '#BF5AF2', false),
('Salud', 'cross.case.fill', '#FF453A', false),
('Servicios', 'bolt.fill', '#FFD60A', false),
('Otros', 'tray.fill', '#8E8E93', false);
