using DataFrames
using CSV
using LibPQ
using Decimals

#ENV["GUROBI_HOME"] = "/home/puc/gurobi952/linux64/"
#ENV["GRB_LICENSE_FILE"]="/home/puc/gurobi.lic"

using Gurobi

include("testesViabi.jl") #Módulo com funções de teste de viabilidade e de ajustes para tornar modelos inviáveis em viáveis
include("preProcess.jl") #Módulo com funções de presolve para agilizar o modelo
include("expVeic.jl") #Módulo com função para aumentar uma matriz em n vezes (nficar uma matriz)

#sAddressCode = pwd()
sAddressCode = "/scratch/" * ENV["USER"]
sAddressCode = "$sAddressCode/"

print("[julia] Importando dados do banco...\n")
#------------------------------------------------- Importando dados do Banco-------------------------------------------------------------------------
nLojasCSV = 20
nVeicCSV = 47
CapaPesoCSV = CSV.File("$(sAddressCode)_6_CAPACIDADE_EM_PESO_DE_CADA_CAMINHÃO_FLOAT_VETOR_NVEIC_select__202210181850.csv") |> DataFrame;
CapaVolCSV = CSV.File("$(sAddressCode)_5_CAPACIDADE_EM_VOLUME_DE_CADA_CAMINHÃO_FLOAT_VETOR_NVEIC_selec_202210181849.csv") |> DataFrame;
CustoCSV = CSV.File("$(sAddressCode)_7_CUSTO_DE_USAR_O_CAMINHÃO_I_PARA_ENTREGAR_NA_LOJA_J_FLOAT_MATR_202210181850.csv") |> DataFrame;
TipoCSV = CSV.File("$(sAddressCode)_11_SE_A_LOJA_I_ACEITA_O_VEÍCULO_BOOLEAN_MATRIZ_NLOJAS_X_NVEIC_s_202210181851.csv") |> DataFrame;
RowVCSV = CSV.File("$(sAddressCode)_14_SE_O_VEÍCULO_I_PODE_REALIZAR_ENTREGAS_EM_ROLLS_OU_GRANEL_boo_202210181852.csv") |> DataFrame;
VolumeCSV = CSV.File("$(sAddressCode)_3_DEMANDA_EM_VOLUME_DE_CADA_LOJA_EM_ROLLS_OU_GRANEL_usei_a_fórm_202210181841.csv") |> DataFrame;
PesoCSV = CSV.File("$(sAddressCode)_4_DEMANDA_EM_PESO_DE_CADA_LOJA_EM_ROLLS_OU_GRANEL_usei_a_fórmul_202210181849.csv") |> DataFrame;
RowLCSV = CSV.File("$(sAddressCode)_13_SE_A_LOJA_I_PODE_RECEBER_EM_ROLLS_OU_GRANEL_boolean_matriz_n_202210181851.csv") |> DataFrame;
TeCSV = CSV.File("$(sAddressCode)_10_TEMPO_DE_DESCARREGAMENTO_DE_CADA_LOJA_COM_E_SEM_ROLLS_FLOAT__202210181850.csv") |> DataFrame;
HoraIniCSV = CSV.File("$(sAddressCode)horarios_inicial.csv") |> DataFrame;
HoraFimCSV = CSV.File("$(sAddressCode)horarios_202210181850.csv") |> DataFrame;
tDesCSV = CSV.File("$(sAddressCode)tempo_entre_lojas - Página1.csv") |> DataFrame;
#-------------------------------------------------------------------------------------------------------------------------------------------------------------

idLoja = PesoCSV[!,:1] #Lista com identificadores das lojas
idCaminhao = CapaVolCSV[!, :1] #Lista com identificadores dos caminhoes

#--------------------------------------------------------------Retirando titulos e rotulos que vieram do CSV----------------------------------------------------------
print("[julia] Retirando títulos e rótulos que vieram do BD...\n")
select!(VolumeCSV, Not([:1]))
select!(PesoCSV, Not([:1]))
select!(CapaVolCSV, Not([:1]))
select!(CapaPesoCSV, Not([:1]))
select!(CustoCSV, Not([:1]))
select!(TeCSV, Not([:1]))
select!(TipoCSV, Not([:1]))
select!(RowLCSV, Not([:1]))
select!(RowVCSV, Not([:1]))
select!(HoraIniCSV, Not([:1]))
select!(HoraFimCSV, Not([:1]))
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

nLojas = 20
nVeic = nVeicCSV[1, 1]

#---------------------------------------------------------------Variaveis auxiliar para iterações---------------------------------------------------------------
S = 1:nLojas 
S_cd = 2:nLojas

V = 1:nVeic

G = 1:2


#--------------------------------------------------Retirando somente as partes dos dados dentro do numero de lojas escolhido------------------------------------------------------------------------------------------------------------

dv = Matrix(VolumeCSV)[1:nLojas,:] #demanda volumetrica

dp = Matrix(PesoCSV)[1:nLojas,:] #demanda barometrica

idLoja = idLoja[1:nLojas,:] #array com ids das lojas

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

rl = Matrix(RowLCSV)[1:nLojas,:] #Matriz com 2 colunas e numero de linhas igual ao numero de lojas ex.: (1, 1) onde o primeiro elemento é 1 se a loja aceita granel e o segundo é 1 se aceita row
rv = Matrix(RowVCSV) #Matriz com 2 colunas e numero de linhas igual ao numero de veiculos ex.: (1, 1) onde o primeiro elemento é 1 se o veiculo aceita granel e o segundo é 1 se aceita row

cv = transpose(Matrix((CapaVolCSV))) #Transpondo a matriz para ficar no formato que estamos usando

constPercRoll = 0.55 #percentual do volume que pode ser ocupado do roll

cv = [(rv[v,1] == 1 ? cv[v]*(constPercRoll) : cv[v]*constPercRoll) for v in V] #Diminuindo em 55% a capacidade dos caminhões que aceitam roll devido ao volume que não poderá ser aproveitado
      
cp = transpose(Matrix(CapaPesoCSV)) #Transpondo a matriz para ficar no formato que estamos usando

#-----------------------------------Formatando a matriz Lojas x Veiculos com os custos do veiculo entregando na loja------------------------------------------------
val = Matrix(CustoCSV) 
val[:1,:] = zeros(1, nVeic)
val = val[1:nLojas,:]
newVal = zeros(nLojas, nVeic)

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#A matriz tDesCSV contém o tempo de deslocamento loja a loja, na linha 71 pegamos a primeira linha dessa matriz para ter o lead time (tempo do CD até a loja)
lt = Matrix(tDesCSV)[1:nLojas,2:(nLojas+1)] #tempo para sair do CD e chegar na loja
lt = lt[:1,:]

ti = transpose(Matrix(HoraIniCSV)) #tempo inicial que a loja pode receber demanda
ti = ti[:, 1:nLojas] #Retirando rotulos do CSV

tf = transpose(Matrix(HoraFimCSV)) #tempo final que a loja pode receber demanda
tf = tf[:, 1:nLojas] #Retirando rotulos do CSV
tf = [i+0.15 for i in tf] #Adicionando 0.15 ao tf para impedir que casos onde o tempo inicial seja igual ao final criem problemas

te = Matrix(TeCSV)[1:nLojas,:] #tempo de descarga da demanda


td = Matrix(tDesCSV) #tempo de deslocamento Loja a Loja (matriz Loja x Loja)
td = td[1:nLojas, 2:(nLojas+1)] #Retirando rotulos do CSV

tipo = Matrix(TipoCSV)[1:nLojas,:] #Matriz Lojas x Veiculos (1 se a loja aceita o veiculo e 0 caso não)

#For loop para converter o volume a granel pro volume com row na segunda coluna das matrizes dv e dp
dp, dv = converteRoll(dp, dv, S)


#----------------------------------Retirando da tipologia aceita veiculos que não podem atender ela por causa da capacidade-------------------------------------------------------

# Função para dividir a demanda de lojas que necessitam ter a demanda dividida 
rl, dv, dp, tipo, idLoja, nLojas, td, te, ti, tf, lt, val = testeVolumePesoUPCSV(rl, cv, cp, dv, dp, tipo, idLoja, nLojas, nVeic, td, te, ti, tf, lt, val)
S = 1:nLojas 
S_cd = 2:nLojas
R = 1:4 #jornada
Rlim = 1:3 #numero maximo de jornadas

multiplicaVeiculo = 1

#Multiplicando todos vetores e matrizes que veiculos aparecem 
tipo = nFicaMatrix(multiplicaVeiculo, tipo, 0)
rv = nFicaMatrix(multiplicaVeiculo, rv, 1)
cp = nFicaMatrix(multiplicaVeiculo, cp, 0)
cv = nFicaMatrix(multiplicaVeiculo, cv, 1)
val = nFicaMatrix(multiplicaVeiculo, val, 0)
nVeic = nVeic*multiplicaVeiculo
V = 1:nVeic

#Pre solve para transformar uns em zeros na matriz de tipologia nos casos de veiculos que podem entrega a demanda da loja, mas não tem capacidade ou são de modalidade diferente da loja (roll/granel) caso seja o modo que não compartilha modalidades diferentes para acelerar o processamento

tipo = formataTipoA(tipo, S_cd, rl, dp, dv, V, rv, cp, cv)

#check para ver se tem alguma loja que é impossivel de ser atendida
for s in S
      if !(1 in tipo[s,:])
            println("Problemas com a loja de indice $s, id $(idLoja[s]), dv=$(dv[s]), dp=$(dp[s]), roll=$(rl[s,1]==1 ? "No" : "Yes")")
      end
end

#convertendo matriz para vetores, já pegando peso, volume e tempo de entrega correspondente se a loja é com row ou não
dp = [(rl[s,1] == 1 ? dp[s,1] : dp[s,2]) for s in S] 
dv = [(rl[s,1] == 1 ? dv[s,1] : dv[s,2]) for s in S]
te = [(rl[s,1] == 1 ? te[s,1] : te[s,2]) for s in S]
cp = [(rv[v, 2] == 1 ? 1 : 1)*cp[v] for v in V]

tf = testeHorario(ti, td, te, tf, nLojas, idLoja)

#recolhendo o tempo de carregamento da demanda considerando se é roll ou granel
tempoCarga = zeros(nLojas)
for i in S
      if rl[i,1] == 1
            tempoCarga[i] = 2
      else
            tempoCarga[i] = 0.5
      end
end


#Criando heuristicas para impedir que o compartilhamento de certas lojas sejam considerados pelo modelo, de forma a acelerar a otimização sem prejudicar o resultado
listHeu, H = makeHeuA(S_cd, td, dv, dp, rl, tf, ti, te)

#listHeu, H = makeHeuB(S_cd, rl)

using JuMP

alis = Model(Gurobi.Optimizer; add_bridges = false) 
# set_optimizer_attribute(alis, "threads", 8)

set_string_names_on_creation(alis, false) #parametro do gurobi para deixar o processamento mais rapido
#set_time_limit_sec(alis, 60.0*16)
set_optimizer_attribute(alis, "Threads", 7) #configurando o uso de threads


#----------------------------Decisão--------------------------------------------

print("[julia] Realizando etapa de decisão...\n")

@variable(alis, 0 <= CH[S,V,R] <= 1800, Int); #criando variavel do horario de chegada em cada loja/rota, considerando o horario em minutos para trabalhar com numeros inteiros (horario de 0 a 1800 equivale 0 a 30 hrs, 30 pois pode ser necessario que o caminhao retorne ao cd depois de meia noite, 24hrs)
@variable(alis, 0 <= saidaCD[V,R] <= 1800, Int); #criando variavel do horario de saida do CD
@variable(alis, A[S,S,V,R], Bin); #criando variavel que vai guardar a rota dos caminhaos (A[X,Y,Z,W]==1 quer dizer que o caminhao Z na rota W vai sair da loja X para ir para loja Y)
@variable(alis, U[V,R], Bin); #variavel auxiliar que diz se um veiculo V esta sendo utilizado ou não em uma rota R
@variable(alis, X[V,R]); #variavel auxiliar que ira guardar os custos de todos fretes
#----------------------------Restrições-------------------------------------------------------


print("[julia] Realizando etapa de restrição...\n")
#Explicação de cada restrição está na documentação do modelo
@constraint(alis, rest1[s in S_cd], sum(sum(sum(A[l,s,v,r] for v in V) for l in S) for r in R) == 1);
@constraint(alis, rest3[v in V, r in R], sum(sum(A[l,s,v,r]*dv[s] for s in S) for l in S) <= cv[v]);
@constraint(alis, rest4[v in V, r in R], sum(sum(A[l,s,v,r]*dp[s] for s in S) for l in S) <= cp[v]);
@constraint(alis, rest5_1[v in V, l in S, s in S, r in R], 60*ti[l] <= CH[l,v,r] + 5000*(1-A[l,s,v,r]));
@constraint(alis, rest5_2[v in V, l in S, s in S, r in R], CH[l,v,r] <= 60*tf[l] + 5000*(1-A[l,s,v,r]));
@constraint(alis, rest6[l in S, s in S, v in V, r in R], A[l,s,v,r] <= tipo[s,v]);
@constraint(alis, rest8[s in S, v in V, r in R], CH[1,v,r] - saidaCD[v,r] <= 10*60 + (1 - A[1,s,v,r])*5000);
@constraint(alis, rest7[l in S, s in S, v in V, r in R], A[l,s,v,r] <= U[v,r]);
@constraint(alis, rest13[l in S_cd, s in S, v in V, r in R], CH[l,v,r] + te[l]*60 + td[l,s]*60 <= CH[s,v,r] + (1 - A[l,s,v,r])*5000);
@constraint(alis, rest14[s in S, v in V, r in Rlim], CH[1,v,r] + tempoCarga[s]*60 <= saidaCD[v,r+1] + (1 - A[1,s,v,r])*5000);
@constraint(alis, rest19[s in S, v in V, r in R], saidaCD[v,r] <= CH[s,v,r] - 60*lt[s] + (1 - A[1,s,v,r])*5000);
@constraint(alis, rest15[s in S, v in V, r in R], sum(A[l,s,v,r] for l in S) == sum(A[s,l,v,r] for l in S));
# @constraint(alis, rest16_1[v in V], sum(A[1,s,v,r] for s in S) == sum(A[l,1,v,r] for l in S));
@constraint(alis, restE1[v in V, r in R], A[1,1,v,r] == 0);
@constraint(alis, restE5[v in V, r in R], sum(A[1,s,v,r] for s in S) == U[v,r]);
@constraint(alis, rest17[l in S, s in S, v in V, r in R], X[v,r] >= val[s,v]*A[l,s,v,r]*(1-1*convertOnes(r)));

@constraint(alis, restExtra2[v in V, r in Rlim], U[v,r+1] <= U[v,r]);




#@constraint(alis, restH[h in H, v in V, r in R], A[listHeu[h][1], listHeu[h][2], v, r] == 0);

#-----------------------------Objetivo----------------------------------------------------------------

print("[julia] Realizando etapa de objetivo...\n")

#@objective(alis, Min, sum(sum(sum(A[s,1,v,g]*val[s,v] for g in G) for v in V) for s in S));
# @objective(alis, Min, sum(sum(X[r] + 0.01*CH[1,v,r] for v in V) for r in R));
@objective(alis, Min, sum(sum(X[v,r] for r in R) for v in V));

optimize!(alis);

status   = termination_status(alis);

#extraindo o resultado otimizado do modelo
custos   = JuMP.objective_value(alis);

CHOpt    = JuMP.value.(CH);
AOpt     = JuMP.value.(A);
UOpt     = JuMP.value.(U);
XOpt     = JuMP.value.(X);
saidaCDOpt = JuMP.value.(saidaCD);


horarioCheg = zeros(nLojas, nVeic, 4)
for i in S
      for j in V
            for r in R
                  horarioCheg[i,j,r] = CHOpt[i,j,r]/60
            end
      end
end
# printaViagem(AOpt, horarioCheg, S, V, rl, cp, cv, R)
include("printaResul.jl")
teste(AOpt, V, R, rl, saidaCDOpt)

#saida_Id caminhao_Id horario_Id Loja_Id hora_chegada

#S S V R


#-----------------------------DataFrame de Saída----------------------------------------------------------------

df = DataFrame(rota=Int[], caminhao_id=Int[], loja_id=String[], hora_chegada=Float64[])
for v in V
    for l in S
          for s in S
                for r in R
                      if AOpt[l,s,v,r] == 1
                            row = [r, idCaminhao[mod(v,10)+1], idLoja[s], CHOpt[s,v,r]/60]
                            push!(df, row)
                      end
                end
          end
    end
end

using CSV
CSV.write("$sAddressCode/resultado.csv", df)

print(df)
# using CSV
# CSV.write("$sAddressCode/resultado.csv", df)
