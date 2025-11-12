<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Arial', sans-serif;
    }

    body {
        background-color: #f5f5f5;
        color: #333;
        line-height: 1.6;
    }

    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }

    header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid #ddd;
        position: relative;
    }

    .menu-hamburguesa {
        display: flex;
        align-items: center;
    }

    .menu-toggle {
        background: none;
        border: none;
        cursor: pointer;
        padding: 10px;
        display: flex;
        flex-direction: column;
        gap: 5px;
        z-index: 1001;
    }

    .menu-toggle span {
        width: 25px;
        height: 3px;
        background-color: #333;
        border-radius: 3px;
        transition: all 0.3s ease;
    }

    .menu-toggle:hover span {
        background-color: #000;
    }

    .sidebar-menu {
        position: fixed;
        top: 0;
        left: -300px;
        width: 300px;
        height: 100vh;
        background-color: #fff;
        box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        transition: left 0.3s ease;
        z-index: 1000;
        overflow-y: auto;
    }

    .sidebar-menu.active {
        left: 0;
    }

    .sidebar-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px;
        border-bottom: 1px solid #ddd;
        background-color: #333;
        color: white;
    }

    .sidebar-header h3 {
        margin: 0;
        font-size: 20px;
    }

    .sidebar-close {
        background: none;
        border: none;
        color: white;
        font-size: 30px;
        cursor: pointer;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        line-height: 1;
    }

    .sidebar-close:hover {
        opacity: 0.7;
    }

    .sidebar-nav {
        padding: 10px 0;
    }

    .sidebar-item {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 15px 20px;
        text-decoration: none;
        color: #333;
        font-size: 16px;
        transition: background-color 0.2s ease;
        border-bottom: 1px solid #f0f0f0;
    }

    .sidebar-item:hover {
        background-color: #f5f5f5;
        color: #000;
    }

    .sidebar-item span {
        font-size: 20px;
    }

    .sidebar-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.5);
        opacity: 0;
        visibility: hidden;
        transition: opacity 0.3s ease, visibility 0.3s ease;
        z-index: 999;
    }

    .sidebar-overlay.active {
        opacity: 1;
        visibility: visible;
    }

    .Botones-Menu-Superior {
        display: flex;
        gap: 10px;
    }

    .Botones-Menu-Superior a {
        text-decoration: none;
        color: #333;
        font-weight: bold;
        font-size: 14px;
    }

    .search-bar-Menu-Superior {
        margin: 20px 0;
        display: flex;
        gap: 10px;
    }

    .search-bar-Menu-Superior input {
        flex: 1;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
    }

    .search-bar-Menu-Superior button {
        padding: 10px 20px;
        background-color: #333;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    @media (max-width: 768px) {
        header {
            flex-direction: column;
            gap: 15px;
        }
        
        .search-bar-Menu-Superior {
            width: 100%;
        }
        
        .Botones-Menu-Superior {
            flex-wrap: wrap;
            justify-content: center;
        }
    }
</style>
