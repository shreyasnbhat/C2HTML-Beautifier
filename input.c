#include<stdio.h>
#define MAXSIZE 1000

int main(int argc, char const *argv[]) {

  int inputs[MAXSIZE];
  int prefSum[MAXSIZE];
  int N;
  int k;
  float m = 3.456;
  int y = 0xFFEA;
  string s = "This is a test string";

  printf("Enter k: ");
  scanf("%d",&k);

  printf("Enter the size of the array: ");
  scanf("%d",&N);

  for (int i = 0; i < N; i++) {
    scanf("%d",&inputs[i]);
  }

  /* This comment might be as long as possible
  without any regrets of its size of length or its ffin syntax
  or whatever.  */


  // prefSum stores sum from 0th element to kth element(included) in prefSum[k]
  prefSum[0] = 0 ;
  for (int i = 1; i < N + 1; i++) {
    prefSum[i] = prefSum[i-1] + inputs[i-1];
  }

  int maxsum = 0;
  int start,end;
  for(int i=0;i<=N-1;i++) {
    for (int j=i+1;j<=N;j++) {
      int diff = prefSum[j] - prefSum[i];
      if(diff > maxsum && diff%k == 0) {
        start = i;
        end = j;
        maxsum = diff;
      }
    }
  }

  printf("The result is %d\n", max_sum/k);
  printf("Start at %d and ends at %d \n", start,end-1);
  return 0;
}
