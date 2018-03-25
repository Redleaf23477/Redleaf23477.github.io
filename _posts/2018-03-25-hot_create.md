---
title: "HandsonTable使用筆記 - Get Started"
tags:
categories:
  - HOT
---

# HandsonTable使用筆記 - Get Started

> 先附上[官方Documentation連結](https://docs.handsontable.com/0.38.1/tutorial-quick-start.html)

## Get Javascript, CSS

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/handsontable/0.38.1/handsontable.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/handsontable/0.38.1/handsontable.min.css">
```



## Construct and Initialize

Handsontable（簡稱hot）的api會把給定的`<div>`轉成試算表，所以先建立一個`<div>`來裝hot，並且給他一個ID。

```html
<div id="hot"></div>
```

接著用Handsontable的Constructor生出一個試算表，語法如下。

```html
<script>
    var hot = new Handsontable(/*目的地div*/, {
        /*所有的設定丟放這裡面*/
    });
</script>
```

範例如下：

```html
<script>
    var hot = new Handsontable(document.getElementById("hot"), {
		data: [
            ["", "Ford", "Tesla", "Toyota", "Honda"],
            ["2017", 10, 11, 12, 13],
            ["2018", 20, 11, 14, 13],
            ["2019", 30, 15, 12, 13]
        ],
        rowHeaders: true,          // 顯示rowHeader
        colHeaders: true,		   // 顯示colHeader
        contextMenu: true          // 在儲存格(cell)右鍵之後顯示選單
    });
</script>
```

hot支援的設定很多，但是官方documentation沒有整理得很完整，建議是要用的時候再去查查看，大部分常用的功能官方文件的Demos都找的到。