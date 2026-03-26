-- ==========================================================
-- 3CC MAIN - NEW SUPABASE PROJECT SETUP SCRIPT
-- Run this entire script in the Supabase SQL Editor
-- ==========================================================

-- 1. Create Tables

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  role TEXT DEFAULT 'user' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sku TEXT NOT NULL UNIQUE,
  price NUMERIC NOT NULL,
  cost NUMERIC NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  category TEXT NOT NULL,
  image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  loyalty_points INTEGER DEFAULT 0,
  total_spent NUMERIC DEFAULT 0,
  visit_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  icon TEXT DEFAULT 'Package' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create daily_registers table
CREATE TABLE IF NOT EXISTS daily_registers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  opened_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  closed_at TIMESTAMP WITH TIME ZONE,
  starting_amount NUMERIC NOT NULL DEFAULT 0,
  ending_amount NUMERIC,
  status TEXT NOT NULL DEFAULT 'open',
  notes TEXT
);

-- Create restaurant_tables table
CREATE TABLE IF NOT EXISTS restaurant_tables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_number TEXT NOT NULL,
  capacity INTEGER DEFAULT 4 NOT NULL,
  status TEXT DEFAULT 'available' NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  owner_id UUID REFERENCES profiles(id),
  subscription_status TEXT DEFAULT 'active' NOT NULL,
  license_expiry TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customers(id),
  total_amount NUMERIC NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  payment_method TEXT NOT NULL,
  order_type TEXT NOT NULL DEFAULT 'dine_in',
  customer_address TEXT,
  server_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT,
  product_category TEXT,
  quantity INTEGER NOT NULL,
  price NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);


-- ==========================================================
-- 2. Enable Row Level Security (RLS)
-- ==========================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_registers ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;


-- ==========================================================
-- 3. Create RLS Policies (Public Access for App Functionality)
-- ==========================================================

-- Profiles
CREATE POLICY "Enable read access for all users" ON profiles FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON profiles FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON profiles FOR DELETE USING (true);

-- Products
CREATE POLICY "Enable read access for all users" ON products FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON products FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON products FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON products FOR DELETE USING (true);

-- Customers
CREATE POLICY "Enable read access for all users" ON customers FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON customers FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON customers FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON customers FOR DELETE USING (true);

-- Orders
CREATE POLICY "Enable read access for all users" ON orders FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON orders FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON orders FOR DELETE USING (true);

-- Order Items
CREATE POLICY "Enable read access for all users" ON order_items FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON order_items FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON order_items FOR DELETE USING (true);

-- Categories
CREATE POLICY "Enable read access for all users" ON categories FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON categories FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON categories FOR DELETE USING (true);

-- Daily Registers
CREATE POLICY "Enable read access for all users" ON daily_registers FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON daily_registers FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON daily_registers FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON daily_registers FOR DELETE USING (true);

-- Restaurant Tables
CREATE POLICY "Enable read access for all users" ON restaurant_tables FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON restaurant_tables FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON restaurant_tables FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON restaurant_tables FOR DELETE USING (true);

-- Restaurants
CREATE POLICY "Enable read access for all users" ON restaurants FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON restaurants FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON restaurants FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON restaurants FOR DELETE USING (true);


-- ==========================================================
-- 4. Create Storage Buckets and Policies
-- ==========================================================

INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true) ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING ( bucket_id = 'product-images' );
CREATE POLICY "Public users can upload" ON storage.objects FOR INSERT WITH CHECK ( bucket_id = 'product-images' );
CREATE POLICY "Public users can update" ON storage.objects FOR UPDATE USING ( bucket_id = 'product-images' );
CREATE POLICY "Public users can delete" ON storage.objects FOR DELETE USING ( bucket_id = 'product-images' );

-- ==========================================================
-- 5. Insert Sample / Initial Data
-- ==========================================================

-- Insert default categories
INSERT INTO categories (name, icon) VALUES
('Beverages', 'Coffee'),
('Food', 'UtensilsCrossed'),
('Snacks', 'Cookie'),
('Desserts', 'Cake'),
('Merchandise', 'ShoppingBag')
ON CONFLICT (name) DO NOTHING;

-- Insert sample products
INSERT INTO products (name, sku, price, cost, stock, category, image) VALUES
('Espresso', 'BEV001', 350, 100, 100, 'Beverages', '☕'),
('Americano', 'BEV002', 400, 120, 100, 'Beverages', '☕'),
('Cappuccino', 'BEV003', 550, 180, 85, 'Beverages', '☕'),
('Croissant', 'FOOD001', 450, 150, 25, 'Food', '🥐'),
('Chocolate Chip Cookie', 'SNK001', 250, 80, 50, 'Snacks', '🍪')
ON CONFLICT (sku) DO NOTHING;

-- Insert sample tables
INSERT INTO restaurant_tables (table_number, capacity, status) VALUES
('T1', 2, 'available'),
('T2', 4, 'available'),
('T3', 4, 'available'),
('T4', 4, 'available'),
('VIP1', 8, 'available')
ON CONFLICT DO NOTHING;
