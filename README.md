# Trabalho Final ACIEPE - PAralelização da propagação de uma onda acústica no domínio 2D usando OpenMP

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

## Estratégia de paralelização
## Versão sequencial de referência
## Versão paralela comentada
## Análise de escalabilidade
### Esperada
### Obtida
## Discussão sobre eficiência da solução
## Conclusões
