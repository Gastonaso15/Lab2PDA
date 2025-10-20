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
