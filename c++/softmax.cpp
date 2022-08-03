#include <iostream>

using namespace std;

float den_expon(float *arr) {
        float s = 0.0f;
        //float sum = 1.0f;

        for (int i = 9; i >= 0; i--) {
                float sum = 1.0f;
                for (int j = 10-1; j > 0; --j) {
                        sum = 1 + arr[i]*sum/j;
                }
                s += sum;
                //cout << "in = " << s << endl;
        }
        return s;
}

float exponential(float x) {
        float sum = 1.0f; //initialize sum of series

        for (int i = 10 - 1; i > 0; --i) {
                sum = 1 + x * sum / i;
                //cout << "sum = " << sum << endl;
        }
        return sum;
}

int main() {
	
	//10 inputs to the softmax module 
	float data_in[10] = {10,9,8,7,6,5,4,3,2,1}; //same input as in testbench "softmax_tb.v"
	float divisor = den_expon(data_in);
	float data_out[10];
	
	for (int i = 0; i < 10; i++) {
		data_out[i] = exponential(data_in[i])/(float)divisor;
		cout << data_out[i] << endl;
	}
	
	
	
	
}
