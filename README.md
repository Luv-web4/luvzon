# 🛒 LuvZon - E-Commerce Web Application

A complete test e-commerce web application developed with **JSP (JavaServer Pages)**, **SQL (MySQL)**, **Bootstrap 5**, and **JavaScript**, designed to run locally on **Apache Tomcat**.

---

## 📑 System Architecture & The 3 Database Tables

As required, the application relies on **3 clean relational tables** defined in [`database.sql`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/database.sql):

1. **`users` (Authentication & Role Management)**:
   - Stores user credentials and classifies them as either a **`producer`** (seller) or a **`user`** (customer).
   - Columns: `id`, `username`, `password`, `role`, `full_name`, `created_at`.

2. **`products` (Producer Inventory)**:
   - Stores products managed by producers across the 6 required categories.
   - Columns: `id`, `name`, `category`, `price`, `description`, `producer_username`, `image_url`, `created_at`.
   - Categories: `electronics`, `medecine`, `toys`, `clothes`, `jwells`, `books`.

3. **`orders` (Customer Purchase History)**:
   - Stores all simulated purchases made by customers.
   - Columns: `id`, `username`, `product_id`, `product_name`, `category`, `price`, `order_date`, `status`.

---

## 🚀 Application Pages & Workflow

| Page | URL / Parameter | Description |
|---|---|---|
| **Login / Register** | [`login.jsp`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/login.jsp) / [`register.jsp`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/register.jsp) | Authentication portal with dual tabs. Asks role during registration (**Producer** vs **Customer**). Routes automatically to respective dashboard. |
| **Producer Dashboard** | [`producer.jsp`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/producer.jsp) | Allows sellers to **Add New Items**, **Edit existing items** (Name, Category, Price, Description, Image), and **Delete Items**. |
| **User Main Page** | [`user.jsp`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/user.jsp) | Customer homepage featuring a **Search Bar**, **6 Category Icons** (`electronics`, `medecine`, `toys`, `clothes`, `jwells`, `books`), popular items grid, and **Order History** section at the bottom. |
| **Category & Search Results** | [`products.jsp?id={category}`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/products.jsp) | Receives the category `id` via JSP query parameter (e.g. `?id=electronics`) or search query, and displays all matching products. |
| **Category Alias** | [`category.jsp?id={category}`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/category.jsp) | Dedicated alias forwarding directly to `products.jsp`. |
| **Product Detail** | [`productDetails.jsp?id={id}`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/productDetails.jsp) | Receives product `id` via query parameter, displays comprehensive product info, and provides the **Buy Now** option. |
| **Purchase Handler** | [`buyProduct.jsp?id={id}`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/buyProduct.jsp) | Inserts the item into the `orders` table without taking any payment. |
| **Order History** | [`orderHistory.jsp`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/orderHistory.jsp) | Displays the customer's purchase history, timestamps, item details, and status. |
| **Logout** | [`logout.jsp`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/logout.jsp) | Terminates the session and returns to login. |

---

## 🛠️ Step-by-Step Setup Guide

### 1. Set Up MySQL Database
1. Open your MySQL client (MySQL Workbench, phpMyAdmin, or MySQL CLI).
2. Execute the included script [`database.sql`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/database.sql):
   ```bash
   mysql -u root -p < database.sql
   ```
   *This automatically creates `luvzon_db`, creates the 3 tables, and seeds initial demo accounts and 42 diverse demo products across all 6 departments.*

> [!TIP]
> If your database tables are already set up and you just want to populate or refresh demo products without wiping existing tables, run [`insert_dummy_products.sql`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/insert_dummy_products.sql).

### 2. Configure Database Connection
Open [`db_config.jspf`](file:///c:/MMMUT%20files/1%20st%20year/IT/project/luvzon/db_config.jspf) and verify your MySQL credentials:
```java
private static final String DB_HOST = "localhost";
private static final String DB_PORT = "3306";
private static final String DB_NAME = "luvzon_db";
private static final String DB_USER = "root";
private static final String DB_PASS = "root"; // MySQL password
```

### 3. Ensure MySQL Connector/J JAR is Present
Tomcat requires the MySQL JDBC driver to communicate with the database:
- Download `mysql-connector-j-8.x.x.jar` (or `mysql-connector-java-5.x.x.jar`).
- Place it in:
  - Apache Tomcat's global library folder: `<Tomcat_Home>/lib/`
  - **OR** in the application folder: `luvzon/WEB-INF/lib/`

### 4. Deploy into Apache Tomcat
**Option A: Direct copy to Tomcat webapps**
1. Copy the entire `luvzon` folder into `<Tomcat_Home>/webapps/luvzon`.
2. Start Tomcat (`bin/startup.bat` on Windows or `bin/catalina.bat run`).
3. Open your browser and navigate to:
   ```
   http://localhost:8080/luvzon/
   ```

**Option B: Using Eclipse / IntelliJ / NetBeans**
1. Import this folder as a Dynamic Web Project.
2. Target your local Apache Tomcat server runtime.
3. Click **Run on Server**.

---

## 🔑 Pre-Configured Demo Credentials

| Role | Username | Password | Purpose |
|---|---|---|---|
| **Customer / User** | `buyer1` | `password123` | Tests shopping, category navigation, buy button, and order history. |
| **Producer / Seller** | `seller1` | `password123` | Tests adding new products, editing info, and deleting items. |

*You can also register brand-new accounts with any custom username and select either role directly on the registration form!*
