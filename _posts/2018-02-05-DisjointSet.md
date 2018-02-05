---
title: "Disjoint Set"
tags:
  - Disjoint Set
  - Data Structure
categories:
  - Template 
---

# 併查集、互斥集、Disjoint Set、Union Find Tree
把同類的節點建成同一棵樹，支援合併（合併兩類）、查詢（兩個節點是否同類）這兩個操作。

## Path Compression
在findroot的時候順便把自己指向root，複雜度O(logN)
```c++
int f[N];

int findrt(int x)
{
    if(f[x] == x) return x;
    else return f[x] = findrt(f[x]);
}

int same(int x, int y)
{
    return findrt(x) == findrt(y);
}

void uni(int x, int y)
{
    f[findrt(y)] = findrt(x);
}

void init()
{
	for(int i = 0; i < N; i++) f[i] = i;
}

```

## Union By Rank
多記錄這棵樹的深度，合併的時候把短的樹併到深的樹（這樣深度才不會增加）。
複雜度降到O(α(N))，其中α(N)是阿克曼函數的反函數（就是一個成長激慢的東東）。
```c++

int f[N]; //disjoint set
int rk[N]; //union by rank

int findrt(int x)
{
    if(f[x] == x) return x;
    else return f[x] = findrt(f[x]);
}

bool same(int x, int y)
{
    return findrt(x) == findrt(y);
}

void uni(int x, int y)
{
    x = findrt(x), y = findrt(y);
    if(x == y) return;
    if(rk[x] < rk[y]) f[x] = y;
    else if(rk[x] == rk[y]) f[x] = y, rk[y]++;
    else f[y] = x;
}

void init()
{
	for(int i = 0; i < N; i++) f[i] = i, rank[i] = 0;
}
```

