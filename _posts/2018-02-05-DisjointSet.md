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
class DisjointSet
{
private:
    static const int N = 1000006;
    int n, fa[N];

public:
    DisjointSet(int sz):n(sz)
    {
        for(int i = 0; i <= sz; i++) fa[i] = i, rk[i] = 0;
    }
    int findroot(int x)
    {
        if(fa[x] == x) return x;
        else return fa[x] = findroot(fa[x]);
    }
    bool same(int x, int y)
    {
        return findroot(x) == findroot(y);
    }
    void uni(int x, int y)
    {
        fa[findroot(x)] = findroot(y);
    }
};
```

## Union By Rank
採用啟發式合併的想法，多記錄這棵樹的深度，合併的時候把短的樹併到深的樹（這樣深度才不會增加）。
合併的時候要注意如果合併的兩個點位於同一個disjoint set，則不做任何處理，不然樹的深度會壞掉。
複雜度降到O(α(N))，其中α(N)是阿克曼函數的反函數（就是一個成長激慢的東東）。

code裡面，rk陣列紀錄的是樹的深度。
```c++
class DisjointSet
{
private:
    static const int N = 1000006;
    int n, fa[N], rk[N];

public:
    DisjointSet(int sz):n(sz)
    {
        for(int i = 0; i <= sz; i++) fa[i] = i, rk[i] = 0;
    }
    int findroot(int x)
    {
        if(fa[x] == x) return x;
        else return fa[x] = findroot(fa[x]);
    }
    bool same(int x, int y)
    {
        return findroot(x) == findroot(y);
    }
    void uni(int x, int y)
    {
        int fx = findroot(x), fy = findroot(y);
        if(fx == fy) return;
        else if(rk[fx] == rk[fy]) fa[fx] = fy, rk[fy]++;
        else if(rk[fx] < rk[fy]) fa[fx] = fy;
        else fa[fy] = fx;
    }
};
```

