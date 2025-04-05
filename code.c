#include <stdbool.h>
#include <stdio.h>

int main(){
    int t[30];
    int i = 0;
    int k = 2;
    while(i < 30){
        bool c = true;
        for (int j = 0; j < i; j++){
            if (k%t[j] == 0){
                c = false;
            }
        } 
        if (c){
            t[i] = k;
            i++;
        }
        k++;
    }
    return 0;
}