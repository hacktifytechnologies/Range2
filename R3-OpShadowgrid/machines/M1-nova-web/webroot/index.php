<?php
// NovaTech Industries — Employee Portal
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NovaTech Industries — Employee Portal</title>
    <link rel="stylesheet" href="assets/style.css">
</head>
<body>
    <header>
        <div class="logo">
            <span class="logo-icon">◈</span>
            <span>NovaTech Industries</span>
        </div>
        <nav>
            <a href="index.php">Home</a>
            <a href="view.php?page=pages/about.php">About</a>
            <a href="view.php?page=pages/news.php">News</a>
            <a href="view.php?page=pages/contact.php">Contact</a>
        </nav>
    </header>
    <main>
        <section class="hero">
            <h1>Welcome to the NovaTech Employee Portal</h1>
            <p>Your central hub for internal resources, announcements, and documentation.</p>
        </section>
        <section class="cards">
            <div class="card">
                <h3>📋 Documents</h3>
                <p>Access internal policy documents and technical guides.</p>
                <a href="view.php?page=pages/about.php">Browse</a>
            </div>
            <div class="card">
                <h3>📰 News</h3>
                <p>Latest company announcements and updates.</p>
                <a href="view.php?page=pages/news.php">Read</a>
            </div>
            <div class="card">
                <h3>📞 Support</h3>
                <p>IT helpdesk and contact information.</p>
                <a href="view.php?page=pages/contact.php">Contact</a>
            </div>
        </section>
    </main>
    <footer>
        <p>© 2024 NovaTech Industries. Internal use only. Unauthorized access is prohibited.</p>
        <!-- Developer note: page viewer at /view.php?page= for dynamic content -->
    </footer>
</body>
</html>
