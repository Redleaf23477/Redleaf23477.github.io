---
title: "Handsontable使用筆記 - callback"
tags:
categories:
  - HOT
---

# Handsontable使用筆記 - callback

> 附上官方Callback的[Demo Page](https://docs.handsontable.com/0.38.1/tutorial-using-callbacks.html#page-source-definition)
>
> 上面列的event都可以自己寫callback，每個callback有哪些參數請參見官方documentation

## callback寫在哪？

有兩種寫法，一種是在initialize hot的時候一起寫在設定裡面，另一種是用addhook。addhook函式吃兩個參數，第一個是event名稱（一個字串），第二個參數是這個event觸發後要幹麻（一個function）。例如現在想要寫beforeChange的callback，像這樣：

```html
<script>
    var hot = new Handsontable(document.getElementById("hot"), {
        data = [],
        ...
        // 第一種，可以放在設定裡面
        beforeChange:function(changes, source){
        	/* Your function here */
    	}
    });
    // 第二種，用addhook
    hot.addhook("beforeChange", function(changes, source){
        /* Your function here */
    });
</script>
```

## callback的`source`參數

[官方的demo page](https://docs.handsontable.com/0.38.1/tutorial-using-callbacks.html#page-source-definition)上面有跳列，其餘的呼叫（例如說在自己的程式裡面呼叫hot的api），`source`為`undefined`。可以用`typeof(source) === "undefined"`判斷。

## [beforeChange](https://docs.handsontable.com/0.38.1/Hooks.html#event:beforeChange), [afterChange](https://docs.handsontable.com/0.38.1/Hooks.html#event:afterChange)

這兩個函式的觸發條件是當有cell（一個或多個）被修改。新增或刪除行列不算。他們的callback function吃的參數有兩個：changes (2D array), source (String)，長這樣：

```javascript
function(changes, source){
    // changes: [[row, prop, oldVal, newVal], ...]
}
```

- `changes`(二維陣列)：存所有被修改的cell資訊，其中每個cell資訊會被存成一維陣列`[ row, prop, oldVal, newVal]`，`row, prop`從0開始編號（即陣列索引值），`oldVal, newVal`分別為修改前/後的值。 總結來說，`changes`長這樣`[ [row0, prop0, oldVal0, newVal0], [row1, cow1, oldVal1, newVal1], ...]`。
    - `prop`：最一開始的col編號（一樣從0開始編號），即使之後column順序有對調，prop不會跟著改變，仍然是最早的col編號。
- `source`（字串），表示是誰做的修改，附上[source list](https://docs.handsontable.com/0.38.1/tutorial-using-callbacks.html#page-source-definition)。

兩個函式的執行順序是：input完 -> `beforeChange` -> 修改data ->` afterChange`。

在hot剛剛被建立起來的時候，`afterChange`會被`loadData`呼叫一次，所以在編寫callback function的時候通常把來自`loadData`的修改特判掉。

### 修改某個cell的cell type

因為官方的`setCellMeta`重複修改單一cell的type會出bug，所以我的作法是在input後把整個row刪掉重新insert一個新的，這個時候就可以用到`beforeChange`。code大概長這樣：

```javascript
this._hot.addHook("beforeChange", function(changes, source){
    // changes: [[row, prop, oldVal, newVal], ...]
    if(source === "loadData" || typeof(source) === "undefined" || changes.length > 1){
        return;
    }
    var row = changes[0][0];
    var col = changes[0][1];
    var nval = changes[0][3];
    if(Columns.headerName[col] === "型別"){                                    
        this.alter("insert_row", row);
        var prv = this.getDataAtRow(row+1);
        for(var i = 0; i < prv.length; i++){
            if(Columns.headerName[col] !== "型別" && Columns.headerName[col] !== "預設值") tableUI._data[row][i] = prv[i];
        }
        this.alter("remove_row", row+1);
        this.setCellMetaObject(row, 5, Type.input[nval]);  //Columns.headerName[5] === "預設值"
        this.validateCells();
    }
});
```

## [beforeCreateCol](https://docs.handsontable.com/2.0.0/Hooks.html#event:beforeCreateCol), [beforeCreateRow](https://docs.handsontable.com/2.0.0/Hooks.html#event:beforeCreateRow), [afterCreateCol](https://docs.handsontable.com/2.0.0/Hooks.html#event:afterCreateCol), [afterCreateRow](https://docs.handsontable.com/2.0.0/Hooks.html#event:afterCreateRow)

在hot裡面，新增或刪除row/column不算在beforeChange/afterChange，他有自己的callback function，長這樣：

```javascript
function(index, amount, source){
    // new col/row at index
    // Number of newly created col/row in the data source array.
}
```

- `index`：新增的row/col的索引值
- `amount`：新增的row/col數量
### 新增一個row並加上初始值

> 這個有在[issue](https://github.com/handsontable/handsontable/issues/1740)出現過，內有code可以參考。

```javascript
this._hot.addHook("afterCreateRow", function(index){
    var headlen = Columns.headerName.length;
    for(var i = 0; i < headlen; i++){
    	this.setDataAtCell(index, i, Columns.defVal[i]);
    }
});
```

