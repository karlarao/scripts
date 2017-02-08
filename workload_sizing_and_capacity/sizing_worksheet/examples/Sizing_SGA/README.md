

## Sizing SGA ##

Question: 
> A colleague asked me a question yesterday to which I don't really have a good answer; so I thought I'd crowdsource it. 
> 
> Given a RAC database of N instances each with an SGA of M gb in size. When changing the instance count N how, if at all, do you modify the value of M? What metrics do you look at, and what is the rationale behind that.
> 
> I'm aware that "let it run for a while and use the memory advisors" is an approach - I can't say I have a lot of confidence in the memory advisors from past experience.   
> 

Answer: 

----------

I agree on measuring the baseline -> make the change -> measure again. And ideally this should be done first on a test/pre-prod environment. And for this I would compare the overall workload (time series viz), do AWR compare periods (memory advisory/wait events - memory issues could show up in wait events), and focus on specific driver SQLs to measure the effect of the change. 

In my opinion the **initial sizing** of the SGA should be determined on the performance tests or benchmarking. Here the iterations of the workload run is done, the changes, the tuning, node failure scenario, and workload characterization. And with all that info SGA can be sized accordingly. 

For **node failure** (reduce nodes), each SGA of nodes can be sized slightly bigger the reasoning behind this is when a node fails the surviving node should be able to take over the Memory resource needs of the failed node. Again, the optimal size can be determined by performance tests or benchmarking. 

Other things to consider: 

**Hugepages**: When the instances are reduced/increased or moved around you need to account for the huge pages settings. It's possible that when these changes are done the huge pages settings could end up undersized or oversized which leads to swapping(kswapd)/node evictions/node hang.   

**PGA**: Similar to the CPU load and SGA. The surviving nodes should also be able to accommodate the PGA requirements of the failing nodes.

The node failure/reduce scenarios can be modeled with the SizingWorksheet [https://github.com/karlarao/sizing_worksheet](https://github.com/karlarao/sizing_worksheet). See the examples folder "SizingSGA.xlsm"

- Let's say we have a database on a X5-2 half rack with:
	- 36 CPUs requirement (50% x 72CPUs) spread out across the four nodes
		- 13% utilization on each node ((50% x 72CPUs)/4)/72
	- 20GB PGA and 20GB SGA       
		- 16% memory utilization on each node 40GB/256GB
		- The 22G HPages is calculated from the SGA with 10% allowance. Just a reminder that this X node needs this much huge pages

![](http://i.imgur.com/rpCbmJa.png)

- If let's say two of the nodes had a server issue and crashed the remaining nodes will increase on CPU and memory utilization 
	- For the CPU, you have less nodes servicing the same CPU requirement 
		- it's basically (36 CPUs divide by 2 remaining nodes) / 72 CPU node capacity = 25% CPU utilization for each remaining host
		- (36/2)/72 = 25%
	- For the memory, the PGA from the failed nodes will be spread on the surviving nodes
		- for node 3 and 4 that's ((existing 40GB SGA and PGA) + 20GB PGA of node1 or node2)/256GB memory node capacity  = 23% memory utilization for each remaining host
		- (40 + 20)/256 = 23%    

![](http://i.imgur.com/KA06miX.png)

Hope this helps


-Karl

----------
