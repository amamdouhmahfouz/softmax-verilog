#include <iostream>

using namespace std;

float exponential(float x) {
        float sum = 1.0f; 

        for (int i = 10 - 1; i > 0; --i) {
                sum = 1 + x * sum / i;
                //cout << "sum = " << sum << endl;
        }
        return sum;
}

int main() {

	//float x = -3.0;
	float x;
	cout << "Enter the number: ";
	cin >> x;
	cout << "exp("<<x<<") = " << exponential(x) << endl;

}
