-- ========================================================
-- Script: insert_dummy_products.sql
-- Run this if you already have the database and just want 
-- to populate or add additional demo products.
-- ========================================================

USE luvzon_db;

INSERT INTO products (name, category, price, description, producer_username, image_url) VALUES
-- Electronics
('Wireless Noise-Canceling Headphones', 'electronics', 89.99, 'Premium over-ear wireless headphones with active noise cancellation and 30-hour battery life.', 'seller1', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80'),
('Ultra-Slim 4K Smart Monitor 27"', 'electronics', 249.50, 'Crisp 4K UHD IPS display with USB-C connectivity and HDR support for productive work and gaming.', 'seller1', 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500&q=80'),
('Smart Fitness Tracker Watch', 'electronics', 49.99, 'Tracks heart rate, sleep stages, daily steps, and sports activities with water resistance.', 'seller1', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80'),
('RGB Mechanical Gaming Keyboard', 'electronics', 69.95, 'Tactile mechanical switches with customizable RGB backlighting and detachable wrist rest.', 'seller1', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500&q=80'),
('Waterproof Portable Bluetooth Speaker', 'electronics', 39.99, 'Compact 360-degree surround sound outdoor speaker with 12 hours of continuous playback.', 'seller1', 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&q=80'),
('20,000mAh Fast-Charging Power Bank', 'electronics', 29.50, 'High-capacity external battery with dual USB-C PD 20W fast charging ports.', 'seller1', 'https://images.unsplash.com/photo-1609592426505-59421a1f0a20?w=500&q=80'),
('1080p Full HD Pro Streaming Webcam', 'electronics', 45.00, 'Crystal-clear video with dual stereo microphones and autofocus for meetings and streaming.', 'seller1', 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=500&q=80'),

-- Medicine
('Comprehensive First Aid Medical Kit', 'medecine', 24.95, '120-piece essential emergency first aid supplies for home, travel, office, and outdoors.', 'seller1', 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=500&q=80'),
('Advanced Multivitamin & Minerals (60 Capsules)', 'medecine', 19.99, 'Daily immune support and vitality formula packed with essential vitamins A, C, D, and Zinc.', 'seller1', 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&q=80'),
('Digital Non-Contact Infrared Thermometer', 'medecine', 29.50, 'Fast 1-second temperature reading with fever alert and backlit LCD display for all ages.', 'seller1', 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=500&q=80'),
('Automatic Upper Arm Blood Pressure Monitor', 'medecine', 39.95, 'Clinically accurate digital BP monitor with large cuff and memory storage for 2 users.', 'seller1', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=500&q=80'),
('Triple Strength Omega-3 Fish Oil (120 Softgels)', 'medecine', 22.00, 'Pure purified fish oil supporting cardiovascular health, joint flexibility, and brain function.', 'seller1', 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&q=80'),
('Soothing Herbal Honey Cough Syrup (200ml)', 'medecine', 11.50, 'Natural honey and ivy leaf extract syrup designed to relieve throat irritation and dry cough.', 'seller1', 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=500&q=80'),
('Ergonomic Electric Heating Pad for Muscle Relief', 'medecine', 32.50, 'Ultra-soft microplush heating pad with 6 heat settings and auto-shutoff timer for pain relief.', 'seller1', 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=500&q=80'),

-- Toys
('High-Speed Remote Control Stunt Car', 'toys', 34.99, '360-degree rotating 4WD off-road RC car with rechargeable battery and LED headlights.', 'seller2', 'https://images.unsplash.com/photo-1594787318286-3d835c1d207f?w=500&q=80'),
('Architecture Building Blocks Set (850 Pcs)', 'toys', 45.00, 'Creative engineering and construction block puzzle set designed to boost cognitive skills.', 'seller2', 'https://images.unsplash.com/photo-1585366119957-e9730b6d0f60?w=500&q=80'),
('Classic Soft Plush Teddy Bear', 'toys', 16.50, 'Ultra-soft, cuddly plush companion crafted with non-toxic, hypoallergenic materials.', 'seller2', 'https://images.unsplash.com/photo-1559454403-b8fb88521f11?w=500&q=80'),
('Mini Foldable Quadcopter Drone with HD Camera', 'toys', 54.99, 'Easy-to-fly mini drone with one-key takeoff, altitude hold, and live Wi-Fi camera transmission.', 'seller2', 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=500&q=80'),
('Wooden Educational Math & Shape Puzzle Board', 'toys', 18.25, 'Montessori-inspired wooden peg puzzle that encourages early counting, sorting, and color recognition.', 'seller2', 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=500&q=80'),
('Kinetic Magic Play Sand Sensory Kit (3 lbs)', 'toys', 15.99, 'Never-dries squeezable kinetic sand with 10 castle sculpting molds and activity tray.', 'seller2', 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=500&q=80'),
('Interactive Programmable Robot with Voice & Sound', 'toys', 28.00, 'Fun gesture-controlled robotic companion that dances, sings, and repeats voice recordings.', 'seller2', 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=500&q=80'),

-- Clothes
('Pure Combed Cotton Casual Oxford Shirt', 'clothes', 32.00, 'Breathable, lightweight button-down casual shirt suitable for office or weekend outings.', 'seller2', 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500&q=80'),
('Classic Slim-Fit Stretch Denim Jeans', 'clothes', 48.00, 'Comfortable flexible denim jeans with 5 pockets, durable stitching, and modern wash.', 'seller2', 'https://images.unsplash.com/photo-1542272604-780c96856592?w=500&q=80'),
('Unisex Cozy Fleece Pullover Hoodie', 'clothes', 39.99, 'Heavyweight soft fleece hoodie with kangaroo pocket and ribbed cuffs for maximum warmth.', 'seller2', 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=500&q=80'),
('Lightweight Breathable Running Shoes', 'clothes', 55.00, 'Shock-absorbing athletic sneakers engineered with mesh knit uppers and anti-slip sole.', 'seller2', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80'),
('Boho Floral Print Summer Maxi Dress', 'clothes', 36.50, 'Flowy, airy tiered summer dress with adjustable waist tie and flattering silhouette.', 'seller2', 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=500&q=80'),
('Modern Slim-Fit Tailored Formal Suit Blazer', 'clothes', 79.00, 'Sharp single-breasted notch lapel jacket designed for formal occasions and celebrations.', 'seller2', 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=500&q=80'),
('Quick-Dry Performance Gym Workout Shorts', 'clothes', 21.99, 'Moisture-wicking athletic shorts with zippered pockets and adjustable drawstring waist.', 'seller2', 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=500&q=80'),

-- Jewelry (jwells)
('Sparkling Diamond Solitaire Pendant Necklace', 'jwells', 120.00, 'Elegant 18K white gold-plated chain featuring a brilliant-cut cubic zirconia solitaire stone.', 'seller2', 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500&q=80'),
('Sterling Silver Infinity Charm Bracelet', 'jwells', 65.50, 'High-polish 925 sterling silver charm bracelet designed with adjustable lobster clasp.', 'seller2', 'https://images.unsplash.com/photo-1611591475152-47e24c6b09f7?w=500&q=80'),
('Freshwater Cultured Pearl Stud Earrings', 'jwells', 42.00, 'Hand-selected luminous round freshwater pearls mounted on hypoallergenic surgical steel posts.', 'seller2', 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500&q=80'),
('Rose Gold Luxury Mesh Band Quartz Watch', 'jwells', 58.00, 'Minimalist analog watch with ultra-thin rose gold casing and scratch-resistant sapphire crystal.', 'seller2', 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=500&q=80'),
('14K Gold Plated Minimalist Stacking Rings Set', 'jwells', 26.50, 'Set of 5 delicate, stackable polished gold bands with micro-pave cubic zirconia accents.', 'seller2', 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500&q=80'),
('Heavy Stainless Steel Curb Link Men\'s Chain', 'jwells', 35.00, 'Durable tarnish-resistant 6mm curb chain crafted with premium 316L medical stainless steel.', 'seller2', 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500&q=80'),
('Vintage Crystal Teardrop Chandelier Earrings', 'jwells', 24.99, 'Shimmering multifaceted Austrian crystals hand-set in antique brass filigree frame.', 'seller2', 'https://images.unsplash.com/photo-1630019852942-f89202989a59?w=500&q=80'),

-- Books
('Clean Code: A Handbook of Agile Software Craftsmanship', 'books', 38.95, 'Seminal programming guide by Robert C. Martin on writing elegant, readable, and maintainable software.', 'seller1', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80'),
('Designing Data-Intensive Applications', 'books', 46.50, 'The definitive guide to the architecture and principles behind modern, distributed big-data systems.', 'seller1', 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=500&q=80'),
('Atomic Habits by James Clear', 'books', 21.00, 'An easy and proven way to build good habits, break bad ones, and achieve remarkable personal growth.', 'seller1', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&q=80'),
('The Psychology of Money by Morgan Housel', 'books', 18.50, 'Timeless lessons on wealth, greed, and happiness exploring how people think about financial decisions.', 'seller1', 'https://images.unsplash.com/photo-1592496431122-2349e0fbc666?w=500&q=80'),
('Deep Work: Rules for Focused Success in a Distracted World', 'books', 22.95, 'Cal Newport\'s actionable framework for cultivating intense concentration and producing peak output.', 'seller1', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80'),
('Sapiens: A Brief History of Humankind', 'books', 24.00, 'Yuval Noah Harari\'s groundbreaking exploration of how Homo sapiens came to dominate planet Earth.', 'seller1', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500&q=80'),
('JavaScript: The Definitive Guide (7th Edition)', 'books', 44.95, 'Comprehensive reference manual for JavaScript programmers by David Flanagan with modern ES2020+ standards.', 'seller1', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=500&q=80');
