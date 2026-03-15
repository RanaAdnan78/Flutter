# 🥿 VELOX — Premium E-Commerce Website
## Setup Guide for Professor Demo

---

## 📂 Project Structure

```
velox/
├── index.php              ← Homepage
├── products.php           ← All products with filters
├── category.php           ← Category listing
├── product_detail.php     ← Product detail + reviews
├── cart.php               ← Shopping cart
├── checkout.php           ← Checkout page
├── order_success.php      ← Order confirmation
├── login.php              ← Login page
├── register.php           ← Register page
├── profile.php            ← User profile
├── my_orders.php          ← Order history
├── wishlist.php           ← Wishlist
├── search.php             ← Search results
│
├── db_connect.php         ← ⚙️ DATABASE CONNECTION (configure here)
├── style.css              ← Main stylesheet
├── header.php             ← Shared header
├── footer.php             ← Shared footer
│
├── add_to_cart.php        ← AJAX: Add to cart
├── update_cart.php        ← AJAX: Update cart qty
├── remove_from_cart.php   ← Remove cart item
├── clear_cart.php         ← Clear entire cart
├── apply_coupon.php       ← Apply coupon code
├── remove_coupon.php      ← Remove coupon
├── wishlist_toggle.php    ← AJAX: Toggle wishlist
├── submit_review.php      ← Submit product review
├── process_order.php      ← Process checkout order
├── logout.php             ← Logout
│
├── includes/
│   └── product_card.php   ← Reusable product card component
│
├── admin/
│   ├── index.php          ← Admin Dashboard (with charts)
│   ├── products.php       ← Manage products
│   ├── add_product.php    ← Add new product
│   ├── edit_product.php   ← Edit product
│   ├── orders.php         ← Manage & update orders
│   ├── categories.php     ← Manage categories
│   ├── users.php          ← View registered users
│   ├── reviews.php        ← Approve/reject reviews
│   ├── coupons.php        ← Create/manage coupons
│   └── sidebar.php        ← Admin sidebar
│
├── uploads/
│   └── products/          ← Product images upload here
│
└── database.sql           ← ✅ Import this first!
```

---

## ⚙️ SETUP STEPS

### Step 1 — Start XAMPP
- Open XAMPP Control Panel
- Start **Apache** and **MySQL**

### Step 2 — Copy Project
- Copy the `velox` folder to: `C:\xampp\htdocs\velox\`

### Step 3 — Import Database
1. Open browser → go to `http://localhost/phpmyadmin`
2. Click **"New"** → Create database named: `velox_db`
3. Select `velox_db` → Click **"Import"** tab
4. Choose the file: `velox/database.sql`
5. Click **"Go"** → Database imported! ✅

### Step 4 — Configure Connection
Open `velox/db_connect.php` and confirm:
```php
define('DB_HOST',     'localhost');
define('DB_USER',     'root');       // XAMPP default
define('DB_PASSWORD', '');           // XAMPP default (empty)
define('DB_NAME',     'velox_db');
define('SITE_URL',    'http://localhost/velox');
```

### Step 5 — Open Website
- **Website:** `http://localhost/velox/`
- **Admin Panel:** `http://localhost/velox/admin/`

### Admin Login Credentials:
```
Email:    admin@velox.com
Password: password
```
*(Change this after logging in!)*

---

## ✨ FEATURES IMPLEMENTED

### Customer Features:
- ✅ Homepage with hero, categories, featured products, new arrivals, sale
- ✅ Product listing with search, filter by category/price/type, sort
- ✅ Full product detail with gallery, size/color picker, reviews, related products
- ✅ Shopping cart with quantity control and AJAX updates
- ✅ Coupon code system (VELOX10, SAVE500, WELCOME15)
- ✅ Checkout with delivery form + payment method selection
- ✅ Order confirmation page
- ✅ User registration & login with password hashing
- ✅ User profile with order history
- ✅ Wishlist management
- ✅ Search functionality
- ✅ Star ratings & review system

### Admin Panel Features:
- ✅ Dashboard with stats (orders, revenue, products, users)
- ✅ Revenue chart (last 6 months)
- ✅ Complete product management (add/edit/delete with image upload)
- ✅ Order management with status updates
- ✅ Category management
- ✅ User management
- ✅ Review moderation (approve/reject)
- ✅ Coupon code management

### Technical Features:
- ✅ MySQL database with 12 tables
- ✅ PHP session management
- ✅ Prepared statements & SQL injection prevention
- ✅ AJAX cart & wishlist (no page reload)
- ✅ Responsive design (mobile friendly)
- ✅ Image upload system
- ✅ BCrypt password hashing
- ✅ Reusable components (header, footer, product card)

---

## 🛒 DEMO COUPONS
| Code | Discount | Min Order |
|------|----------|-----------|
| VELOX10 | 10% off | Rs. 2,000 |
| SAVE500 | Rs. 500 off | Rs. 3,000 |
| WELCOME15 | 15% off | Rs. 1,000 |

---

## 🗄️ DATABASE TABLES
1. `users` — Customer & admin accounts
2. `categories` — Product categories
3. `brands` — Shoe brands
4. `products` — All products
5. `cart` — Shopping cart items
6. `orders` — Customer orders
7. `order_items` — Items in each order
8. `wishlist` — User wishlists
9. `reviews` — Product reviews
10. `coupons` — Discount coupons
11. `settings` — Site settings
12. `banners` — Promo banners

---

*VELOX E-Commerce — Built with PHP, MySQL, XAMPP*
*All rights reserved © 2025*
