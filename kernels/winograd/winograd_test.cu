#include "winograd.cu"

#include<random>
#define LOOP(x) for(int t##x = 0; t##x < x; t##x++)
using namespace std;

int main(void) 
{
    auto engine = default_random_engine(7);
    auto rng = uniform_real_distribution<float>();
    int bs, ch, h, w, och, pad; 
    //bs - batch size, ch - input channel, h - input height, w - input weight , pad - padding required
    
    bs = 2;
    ch = 2;
    h = 5;
    w = 5;
    och = 1;
    pad = 0;
    size_t insize = bs * ch * h * w * sizeof(float);
    float *in = new float[insize/sizeof(float)];
    float *t = in;
    float  *cutY; //final convolved output
    size_t tsize = och*ch*3*3;
    float *kernel_weights = new float[tsize];
    float *tkw = kernel_weights;
    //put kernel weights
    LOOP(tsize)
    {
        tkw[ttsize] = 0;
    }
    tkw[0] = tkw[8] = 1;
    tkw[9] = tkw[17] = 2;
    //put input
    LOOP(bs)
    {
        LOOP(ch)
        {
            LOOP(h)
            {
                LOOP(w)
                {
                    *(t++) = rng(engine);
                }
            }
        }
    }
    LOOP(bs)
    {
        cout<<"{ ";
        LOOP(ch)
        {
            cout<<"{ ";
            LOOP(h)
            {
                cout<<"{ ";
                LOOP(w)
                {
                    cout<<in[((tbs*ch+tch)*h+th)*w+tw]<<" ";
                }
                cout<<"}\n";
            }
            cout<<"}\n";
        }
        cout<<"}\n";
    }
    cout<<"\nConvolving\n";
    
    int oph, opw; //output height, output weight
    cutY = WING::forward(och, ch, bs, h, w, pad, in, oph, opw, kernel_weights);

    cout<<"\nConvolution finished\n\n";
      
    LOOP(bs)
    {
        cout<<"{ ";
        LOOP(och)
        {
            cout<<"{ ";
            LOOP(oph)
            {
                LOOP(opw)
                {
                    cout<<cutY[((tbs*och+toch)*oph+toph)*opw+topw]<<",";
                }
                cout<<";\n";
            }
            cout<<"}\n";
        }
        cout<<"}\n";
    }
    cout<<"}\n";
    return 0;
}