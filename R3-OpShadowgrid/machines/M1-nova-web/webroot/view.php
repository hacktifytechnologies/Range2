<?php
// NovaTech Document Viewer
// Developer: "Added basic path restriction — should be safe"
// Note: str_replace only strips ONE occurrence — bypass with ....// etc.
//       Also: no restriction on absolute paths or PHP wrappers.

$page = $_GET['page'] ?? 'pages/home.php';

// Weak sanitization (single-pass — bypassable)
$page = str_replace('../', '', $page);

// Log visit (useful for debugging, definitely not a security risk... right?)
// Access is logged to /var/log/novatech_access.log automatically by Apache

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>NovaTech — Document Viewer</title>
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
        <div class="content">
<?php
// Include the requested page — LFI vulnerability here
@include($page);
?>
        </div>
    </main>
    <footer>
        <p>© 2024 NovaTech Industries. Internal use only.</p>
    </footer>
</body>
</html>
