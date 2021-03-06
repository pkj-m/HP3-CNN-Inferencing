
# Memory Usage Profiling - Introduction

This profiling setup runs a forward pass of the VGG architecture for a single image and profiles the memory being used through ``nvidia-smi`` command. It then plots a comparison of the GPU usage pattern for the different kernels. 
  

# Measuring GPU Usage
In order to measure the GPU usage, we take a naive, yet effective, approach (and that is why this is an experimental profiler) and use the `nvidia-smi` command to log the GPU memory being used at regular intervals

**Command Used:**
```
$ nvidia-smi --query-gpu=memory.used --format=csv -lms 10 > memory_<KERNEL NAME>.txt &
```

We run this command in the background before running the forward pass inferencing and the memory usage is logged in the memory_< Kernel Name>.txt file. 

>  **Note** - Due to the requirement of running background processes, this will not work on Colab 
  

# Experimental Setup
*  **Logger**  [`gpuMemProfiler.cc` and `memProfiler.sh` ]
	The C++ scripts just runs a forward pass of the VGG-19 architecture for 1 image with the given algorithm
The bash script is the main logger which before running the forward pass binary generated by the above script, issues the nvidia-smi command for profiling and kills it after the run for each algorithm

*  **Analyzer**  [`memoryAnalyzer.py`]
	It takes the logfiles generated by the logger and generate the memory usage plot


# How to Run the Code
 * **Compilation:**   `$ make`  [Can be skipped if compiled through the global makefile]
* **Running the C++ and Bash based logger:**
	```
	$ make run
	```
	By default, this code runs 1 forward pass of each kernel on VGG with batch_size = 1 while a special setting of the nvidia-smi commands logs the memory usage in background. This will generate 5 files  - `memory_cudnn.txt`, `memory_direct.txt`, `memory_fft.txt`, `memory_im2col.txt`, `memory_winograd.txt` 
	

	> In case, you encounter any issues with `make run`, manually run the `memProfiler.sh` script and try 

* **Running the Analyzer:**
	The analyzer can be run be as follows:
	```
	$ python memoryAnalyzer.py
	```
	This will take whatever of the above mentioned files are present in the directory and generate plots in the `profiling/MemoryUsageProfiling/Plots/` folder   

* **Clean the test directory:**  ```$ make clean```
  

# Experimental Results

### <ins>VGG-19</ins>
![](https://github.com/prajwal1210/HP3-CNN-Inferencing/blob/master/profiling/MemoryUsageProfiling/Plots/GPUMemoryUtilization.png)

From the plot above, we can draw the following conclusions:
* CUDNN, Im2Col and Direct Convolutions require very less memory
* Since CUDNN, Im2Col and Direct don't loop on the batch-size, we expect the memory to scale linearly [We haven't tested for batchsize = 8 yet]
* FFT and Winograd use significantly larger memory. This also explains why they have higher overheads. Both of these algorithms are looping on the batch in our implementation, hence, we expect the requirement to remain around the same
* This huge memory requirement of FFT and Winograd was a bottleneck due to which we could not parallelize the same algorithms on multiple batches directly