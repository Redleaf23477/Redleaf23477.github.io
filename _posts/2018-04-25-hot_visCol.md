---
title: "Handsontable使用筆記 - visual Row / Col"
tags:
  - HOT
categories:
  - HOT
---

# Handsontable使用筆記 - visual Row / Col

> 在寫 afterChange 跟 getDataAtXXX / getColHeader ... 時，對於Row Col的編號方式要很小心。
>
> 簡單來說，prop 跟 visual Row / Col index 是不一樣的

Handsontable有data binding的功能，意思是在你修該網頁上UI中cell的值得同時，你原本當作表格資料傳進去的二維陣列（也就是初始化hot時的`data`）也會被修改。但是對於交換整排row/col順序的這些操作並不回影響到丟進去的二維陣列。

## [afterChange](https://docs.handsontable.com/2.0.0/Hooks.html#event:afterChange)

文件說`change`是個長這樣的二維陣列：`[[row, prop, oldVal, newVal], ...`，其中`prop`為他在`data`二維陣列中的索引值。因此，就算移動欄位順序，prop依舊不變。

## [getDataAtCell等等](https://docs.handsontable.com/2.0.0/Core.html#getDataAtCell)

文件中註明，row 和 col 為 **Visual** xxx index。意思是如果改變過順序，row 和 col 也會跟著改變。要注意的一點是，這個index一樣從0開始編號。