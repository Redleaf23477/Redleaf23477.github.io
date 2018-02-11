---
title: "Searching"
tags:
  - DFS
  - BFS
  - BiBFS
  - IDDFS
  - A*
  - IDA*
categories:
  - Algo Notes
---

# 各種搜尋
遇到問題的時候，可以先把他的狀態列出來，然後轉成圖。
找問題答案的方法，就是在圖中搜尋，找出我們想要的狀態。

搜尋的演算法有幾種：
最基本的就是DFS跟BFS，稍稍優化一下有BiBFS跟IDDFS，
配上評估函數優化的話，有A\*跟IDA\*。

是說下面的code理論上是對的，但是都沒實測過。如果有bug請聯絡我，我盡速修正。

[TOC]

## DFS 深度優先搜尋
DFS = Depth First Search。
遍歷圖的時候，DFS會先往最深的地方衝，直到當前節點的每一條路都走過了才退回上一層，找另一條路繼續搜尋。
實做的時候可以用遞迴或stack，不過個人偏好用遞迴。

下面是一個dfs遍歷整個圖的code。

```c++
const int VN = 100;    // number of vertices
vector<int> graph[VN]; // using Adjacency Matrix, graph[vertex_idx] = neighboring_vertex
bool vis[VN];          // store whether a vertex is visited in dfs

void dfs(int idx, int f)
{
    vis[idx] = true;
    for(auto c:graph[idx])
    {
        if(c == f) continue;      // do not go backwards
        if(!vis[c]) dfs(c, idx);
    }
}

```

## BFS 廣度優先搜尋
BFS = Breadth First Search。
遍歷圖的時候，BFS會依照深度由最淺往最深搜尋，當這個深度的所有點都遍歷過了才換下一層的點遍歷。
實做的時候需要搭配queue服用。

下面是一個bfs遍歷圖的code。實做時務必記得，先標記這個節點已經經過了，再丟進queue裡面。

```c++
const int VN = 100;    // number of vertices
vector<int> graph[VN]; // using Adjacency Matrix, graph[vertex_idx] = neighboring_vertex
bool vis[VN];          // store whether a vertex is visited in bfs 

void bfs(int start_v)  // starting vertex
{
    queue<int> que;
    que.push(start_v);
    vis[start_v] = true;
    while(!que.empty())
    {
        int f = que.front(); que.pop();
        for(auto c:graph[f])
        {
            if(!vis[c])
            {
                vis[c] = true;
                que.push(c);
            }
        }
    }
}
```


## BiBFS
BiBFS = Bidirectional BFS，意思是雙向BFS。
相較於傳統的BFS只從起點擴散，BiBFS從起點和終點同時做BFS。
當兩邊BFS的時候相遇了，就找到從起點到終點的最短路了。

BiBFS的優點是它比BFS還要省記憶體。
假設最短路長度=d，每個節點都有N個邊，BFS就要在queue裡面放的複雜度是\mathbfO({N^d})。
BiBFS找到最短路時，兩個queue各跑了d/2的深度，空間複雜度下降到\mathbfO({N^(d/2)})。

下面是BiBFS在圖中找最短路的code（不過只有找到，沒有回傳長度呵呵），基本上長的跟BFS差不多。

```c++
const int VN = 100;    // number of vertices
vector<int> graph[VN]; // using Adjacency Matrix, graph[vertex_idx] = neighboring_vertex
bool s_vis[VN];        // for bfs starting from start
bool e_vis[VN];        // for bfs starting from end

void bibfs(int vs, int ve)                     // starting vertex and ending vertex
{
    queue<int> s_que, e_que;                 // bfs from start, bfs from end
    s_que.push(vs);
    s_vis[vs] = true;
    e_que.push(ve);
    e_vis[ve] = true;

    while(!s_que.empty() && !e_que.empty())
    {
        int sf = s_que.front(); s_que.pop();
        for(auto c:graph[sf])
        {
            if(e_vis[c]) return;              //shortest path found, terminate
            if(!s_vis[c])
            {
                s_vis[c] = true;
                s_que.push(c);
            }
        }
        int ef = e_que.front(); e_que.pop();
        for(auto c:graph[ef])
        {
            if(s_vis[c]) return;              //shortest path found, terminate
            if(!e_vis[c])
            {
                e_vis[c] = true;
                e_que.push(c);
            }
        }
    }
}

```

## IDDFS
IDDFS = iterative deepening search，維基百科說它叫迭代深化深度優先搜尋。

DFS在遍歷圖找最短路的時候，第一個找到的解不保證是最佳解，BFS又太容易MLE。
我們希望有一個能找最佳解，又不太肥的東西，因此IDDFS就誕生了！

IDDFS跟DFS很像，只是每次遞迴的時候會限制深度，超過深度限制就折返。
如果找不到解，就增加深度限制繼續遞迴。
每次遞迴的時候都從起點重新算起，不紀錄上一次遞迴的資訊，以節省記憶體。

下面是IDDFS找最短路的code。其實我沒在題目用過IDDFS，下面的code是從IDA\*改的。
IDDFS每次回傳的是下一次遞迴深度限制。如果答案找到了，那就改成回傳答案的值。

```c++
const int VN = 100;    // number of vertices
vector<int> graph[VN]; // using Adjacency Matrix, graph[vertex_idx] = neighboring_vertex
bool vis[VN];          // store whether a vertex is visited in dfs
bool found;            // indicate whether the ans is found
int v_ans;             // the answer vertex to find

int iddfs(int idx, int f, int depth, int bound) // idxth vertex, prev vertex, depth, bound of depth
{
    if(depth > bound) return depth;
    if(idx == v_ans) { found = true; return depth; }

    int nxtbound = (1<<30); 
    for(auto c:graph[idx])
    {
        if(c == f) continue;
        if(!vis[c])
        {
            vis[c] = true;
            int res = iddfs(c, idx, depth+1, bound);
            if(found) return res;
            else nxtbound = min(nxtbound, res);
            vis[c] = false;
        }
    }
    return nxtbound;
}

void process()
{
    int bound = 0;
    while(!found) bound = iddfs(0, 0, 0, bound); // when found == true, iddfs will return the ans
    cout << bound << endl;
}
```

## 評估函數
評估函數是幹麻的？
假如有一個沒有障礙物的平面，終點在起點右邊7122格的地方，最短路當然是向右走7122次。
可是電腦不知道這回事，
用BFS（四方擴散）的話，87%的機率會MLE；用BiBFS，78%的機率會MLE；用IDDFS，87%的機率會TLE。
因此我們可以透過評估函數，讓告訴電腦往哪邊走比較可能找到終點，不用暴力走完整張地圖。

評估函數`f(x) = g(x) + h(x)`，其中
`x` 這個參數是當前節點，
`g(x)` 是你已經有的深度，
`h(x)` (heuristic function) 是你**評估**當前點到終點多遠。

在搜尋的時候，我們可以把評估函數當作key，每次往key最好的方向（也就是越有可能出現答案的方向）搜尋。
像上述例子的話，我們的h(x)可以設成當前節點到終點的距離差（\Delta x + \Delta y)，
每次找f(x)最小的點出來搜尋。

## A\*
我對這個東東的理解是，把bfs中的queue改成prioirity queue，排序的原則是f(x)遞增（每次pop出最小值）。

下面是一個不完整的code。只是寫個A\*的雛型。完整的code可以參見TIOJ1573那篇。
```c++
struct Node
{
    int v, f, step;    // vertex idx, function val, step while bfs
    Node(int vv, int ff, int ss):v(vv), f(ff), step(ss){};
};
struct Cmp
{
    bool operator() (Node &a, Node &b) { return a.f > b.f; }
};
typedef priority_queue<Node, vector<Node>, Cmp> PQ;

const int VN = 100;    // number of vertices
vector<int> graph[VN]; // using Adjacency Matrix, graph[vertex_idx] = neighboring_vertex
bool vis[VN];          // store whether a vertex is visited in bfs 
int ans;               // the answer vertex we want to find

int h(int vidx);       // return heuristic function value

int astar(int sv)       // sv: starting vertex
{
    PQ pq;
    pq.push(Node(sv, 0+h(sv), 0));
    vis[sv] = true;
    while(!pq.empty())
    {
        Node tp = pq.top(); pq.pop();
        for(auto c:graph[tp.v])
        {
            if(c == ans) return tp.step+1;
            if(!vis[c]) 
            {
                vis[c] = true;
                pq.push(Node(c, tp.step+1+h(c), tp.step+1));
            }
        }
    }
}
```

## Heuristic Function 對 A\*的影響
分下列情況討論：[ref:heuristic&astar]
1. **h(x) = 0** 也就是f(x) = g(x)，這樣A\*就變成Dijkstra了。
1. **h(x)不高估** 也就是h(x) <= x到終點的實際距離，這個時候可以找到最短路徑。
當h(x)估的越準，A\*的效率就越高。
當h(x)等於到x到終點實際距離，A\*就會沿著最短路跑過去，達到最高效率。
1. **h(x)高估** 這個時候不會找到最短路，但是可以花較少的時間找到夠好的解。
1. **h(x)跟g(x)高度相關** 這個時候A\*會變成Best-First-Search，就是不管有沒有障礙，往終點值直衝。

## IDA\*
DFS跟BFS合體變IDDFS，IDDFS跟A\*合體變IDA\*。

code 的長相跟 IDDFS 有八成七像，只是多了h(x)。

```c++
const int VN = 100;    // number of vertices
vector<int> graph[VN]; // using Adjacency Matrix, graph[vertex_idx] = neighboring_vertex
bool vis[VN];          // store whether a vertex is visited in dfs
bool found;            // indicate whether the ans is found
int v_ans;             // the answer vertex to find

int h(int idx);        // heuristic function

int idastar(int idx, int f, int depth, int bound) // idxth vertex, prev vertex, depth, bound of fx
{
    int hx = h(idx);
    if(depth+hx > bound) return depth+hx;
    if(idx == v_ans) { found = true; return depth; }

    int nxtbound = (1<<30); 
    for(auto c:graph[idx])
    {
        if(c == f) continue;
        if(!vis[c])
        {
            vis[c] = true;
            int res = iddfs(c, idx, depth+1, bound);
            if(found) return res;
            else nxtbound = min(nxtbound, res);
            vis[c] = false;
        }
    }
    return nxtbound;
}

void process()
{
    int bound = 0;
    while(!found) bound = idastar(0, 0, 0, bound); 
    cout << bound << endl;
}
```

---------
#### 參考資料：
1. 建中資訊社講義2015版
1. [Lecture 9 | Search 6: Iterative Deepening (IDS) and IDA*](https://www.youtube.com/watch?v=5LMXQ1NGHwU)
1. [Amit’s A\* Pages](http://theory.stanford.edu/~amitp/GameProgramming/)

[ref:heuristic&astar]: http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#a-stars-use-of-the-heuristic
