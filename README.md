# Trabalho Final ACIEPE - Paralelização da propagação de uma onda acústica no domínio 2D usando OpenMP

## Grupo
Ana Carolina Castro Rosal - 769679

Pedro Lemos Mandim - 769801

## Descrição do problema
  O espalhamento de ondas acústicas tem sido considerado um tópico de interesse prático para diferentes áreas. Trabalhos relevantes são reportados no design de antenas e sensores, no desenvolvimento de sistemas de comunicação sem fio, na previsão do dano de terremotos, na modelagem de fluidos dinâmicos e na geofísica para, por exemplo, o estudo dos solos com o objetivo de extrair ou encontrar petróleo.
  
  Resolver esses problemas demanda um esforço computacional muito grande e, em alguns casos, tornam a simulação proposta quase impraticável. A abordagem de usar ferramentas como OpenMP, pode suavizar essa limitação.
  
  Alguns métodos numéricos são necessários para prover uma solução aproximada para problemas de propagação de onda reais. Geralmente, a modelagem numérica do espalhamento de ondas acústicas requer soluções para espaços de alta dimensão e a discretização do domínio pode conter milhões de elementos, o que gera uma significativa carga computacional. Por isso, a simulação do fenômeno de espalhamento de ondas acústicas é
uma tarefa computacional exigente.

  Pode-se dizer que a equação de onda é uma equação diferencial linear de segunda ordem que descreve o comportamento de uma onda sonora com o passar do tempo, dentre outros tipos de ondas, onde todas elas descrevem uma perturbação média. O meio da onda
sonora é descrito por P(x,y,z,t) e u(x,y,z,t), onde P é a pressão do meio e u é o deslocamento da partícula. A relação entre a pressão e o deslocamento da partícula é dados por
com k representando o módulo de compressão volumétrica. 

  Uma das hipóteses do modelo considerado é que a pressão do meio é invariável no eixo z, o que implica que a derivada parcial em relação ao eixo z é zero. Portanto, a equação de onda
no espaço 2D é dada pela Equação 1, onde P = P(x,y,t), x e y são as coordenadas cartesianas, t é o tempo, c é a velocidade da onda acústica e f(x,y,t) é a função de origem.
![Captura de tela de 2023-08-31 19-31-32](https://github.com/anacarolinarosal/Trabalho-Final-ACIEPE/assets/136752200/c604fa5c-3fc1-47a6-8f4a-796755348b17)

  Das soluções para domínios de grande dimensão, um único processador pode ser limitado ou, geralmente, incapaz de lidar com a memória necessária e as exigências computacionais. Com o objetivo de melhorar a performance desses métodos diferenciais
finitos, é necessário explorar outras estratégias computacionais, como a paralelização.

## Estratégia de paralelização
  A estratégia de paralelização usada neste trabalho foi a interface de programação OpenMP (Open Multi-Processing) que possibilita o desenvolvimento de programa em C, como foi feito nesse trabalho.

  A vantagem do OpenMP é que ele é um moodelo portável e escalável que provê uma interface simples e flexível para o desenvolvimento de aplicações paralelas para a execução em computadores com memória compartilhada. ALém disso, diferentes arquiteturas são surpotadas, como a plataforma Unix, utilizada neste trabalho.

  O código sequencial em que este trabalho se baseou está na pasta _examples/acustic_wave_.

  As execuções dos códigos sequenciais e paralelos foram feitas em _local host_, sendo um computador que possui 8 CPU'S, 2 threads por núcleo, 1 soquete e 4 núcleos por soquete. O modelo é INtel COre i7-8550U de 1.80GHz.
  
## Versão sequencial de referência
  O trecho da versão sequencial de referência é a seguinte:
```cpp
for(int n = 0; n < iterations; n++) {
        for(int i = HALF_LENGTH; i < rows - HALF_LENGTH; i++) {
            for(int j = HALF_LENGTH; j < cols - HALF_LENGTH; j++) {
                // index of the current point in the grid
                int current = i * cols + j;
                
                //neighbors in the horizontal direction
                float value = (prev_base[current + 1] - 2.0 * prev_base[current] + prev_base[current - 1]) / dxSquared;
                
                //neighbors in the vertical direction
                value += (prev_base[current + cols] - 2.0 * prev_base[current] + prev_base[current - cols]) / dySquared;
                
                value *= dtSquared * vel_base[current];
                
                next_base[current] = 2.0 * prev_base[current] - next_base[current] + value;
            }
        }
```
  Esse loop faz o cálculo da propagação da onda acústica para cada objeto da matriz após um número de iterações, com o objetivo de observar o resultado dessa propagação depois através da imagem gerada em python, como é feito no código original.
  
## Versão paralela comentada
  A versão paralelizada do loop do cálculo da propagação da onda acústica está logo abaixo:
```cpp
for(int n = 0; n < iterations; n++) {
        #pragma omp parallel for collapse(2)
        for(int i = HALF_LENGTH; i < rows - HALF_LENGTH; i++) {
            for(int j = HALF_LENGTH; j < cols - HALF_LENGTH; j++) {
                // index of the current point in the grid
                int current = i * cols + j;

                //neighbors in the horizontal direction
                float value = (prev_base[current + 1] - 2.0 * prev_base[current] + prev_base[current - 1]) / dxSquared;
                
                //neighbors in the vertical direction
                value += (prev_base[current + cols] - 2.0 * prev_base[current] + prev_base[current - cols]) / dySquared;
                
                value *= dtSquared * vel_base[current];
                
                next_base[current] = 2.0 * prev_base[current] - next_base[current] + value;
            }
        }
```
  Nesse caso, foi utilizada a diretiva #pragma omp parallel for collapse(2), porque ela consegue agrupar loops aninhados em blocos de iteração maior, o que agiliza o cálculo, principalmente para problemas de alta escala, como acontece com o problema tratado neste trabalho.
  
## Análise de escalabilidade
### Esperada
  Sobre a escalabilidade, o número de threads usado no código tem que variar entre 1 e 8 threads para que o programa paralelo realmente seja mais eficiente do que o sequencial. Isso acontece, porque o computador em que o código paralelo foi executado possui 8 núcleos de processamento, assim o paralelismo real é limitado a 8 threads.

  Se mais threads forem utilizadas, acima de 8, o programa fará um _swap_ de execução, dispondo tarefa entre as threads disponíveis, tendo em vista que o hardware tem limitações de threads simultâneas e o SO tem que alocar de alguma maneira os processos, o que gera um perda de performance, porque, por incapacidade do harware, o software terá que executar outras threads, perdendo o paralelismo verdadeiro.

  Além disso, se espera que aumentar o tamanho do problema, ou seja, o tamanho da matriz a ser calculada, aumente o speedup, tendo em vista que a granularidade ficará mais grossa , portanto, o tempo de _swap_ entre tarefas não será menor do que o tempo para executar a tarefa em si, tendo em vista que o _collapse_ faz exatamente isso de aumentar o bloce trabalho a ser realizado por um thread.
  
### Obtida
  O código paralelo e o sequencial foram executados 5 vezes para que se obtivesse o resultado médio dos tempos de execução e, para o caso do código paralelo, foram usadas 2, 4 e 8 threads. Os resultados dos tempos de execução para a matriz de dimensão 1000 x 1000 e tempo de propagação 5000 ms estão no gráfico de barras abaixo:
  ![image](https://github.com/anacarolinarosal/Trabalho-Final-ACIEPE/assets/136752200/6ed9f4b9-5f2b-4973-87af-15f73e8383f3)
  
  Para a matriz de dimensão 2000 x 2000, com o mesmo tempo de propagação, os resultados do tempo de execução estão no gráfico de barras abaixo:
  
  ![image](https://github.com/anacarolinarosal/Trabalho-Final-ACIEPE/assets/136752200/0b3a32ea-9966-4503-afda-962bdee28697)

## Discussão sobre eficiência da solução
  Sobre a solução paralela proposta, é possível perceber que ela reduz o tempo de execução tanto com o aumento de threads, como também com o aumento do problema, como era esperado. Indicando que a paralelização obteve sucesso.

  Além disso, é interessante ressaltar que, com o aumento do número de threads, o desempenho não vai reduzindo pela metade, exatamente, porque, apesar do problema ser grande, ele ainda não tem granularidade grossa para fazer com que o _swap_ entre threads seja mais proveitoso. 
  
  Isso acontece, porque a operação feita pela thread, que contém algumas operações matemáticas, é pequena se comparada à dimensão do problema, o que torna a execução feita por duas threads duas vezes mais rápida do que a execução feita por uma, mas, comparando 2 e 4 threads, o uso de 4 threads não reduz o tempo de execução pela metade em relação ao uso de 2 threads, o que era esperado pela granularidade ser fina.
  
## Conclusões
  Conclui-se, portanto, que, para o problema de paralelização  do cálculo da propagação da onda acústica utilizando OpenMP, a paralelização obteve sucesso, tendo em vista que o tempo de execução paralelo reduziu bastante em relação ao tempo sequencial.
  
  Esse resultado era esperado, tendo em vista que o aumento do bloco de trabalho por meio da diretiva paralela com a cláusula _collapse_ melhora  desempenho do programa, porque fornece um bloco de trabalho maior para cada um das threads.
  
  Como foi discutido, o aumento do número de threads não reduz proporcinalmente o tempo de execução, porque a granulariade do problema a ser resolvido passa a ser fina, o que gera um _overhead_ de execução devido a troca de tarefas entre threads.

  Mesmo assim, foi interessante colocar em prática o conhecimento teórico de OpenMP para resolver um problema prático como esse, amplamente utilizado em diversas aplicações.
