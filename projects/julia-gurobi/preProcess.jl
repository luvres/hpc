using Decimals

#Fazendo com que caminhoes que lojas aceitem, mas que nao possuem capacidade para entregar na loja ou que sao de uma modalidade (roll/granel) nao sejam considerados pelo modelo naquela loja
function formataTipoA(tipo, S_cd, rl, dp, dv, V, rv, cp, cv)
      for s in S_cd #considerando todas as lojas menos o CD 
          g = (rl[s,1] == 1 ? 1 : 2)
          pesDem = dp[s,g]
          volDem = dv[s,g]
          for v in V
                if (rv[v,g] == 0 || cp[v] < pesDem || cv[v] < volDem)
                      tipo[s,v] = 0
                end
          end
    end
    return tipo
end

# A mesma coisa que a função de cima, mas levando em conta que caminhoes que são de roll tb podem entregar a granel
function formataTipoB(tipo, S_cd, rl, dp, dv, V, rv, cp, cv)
    for s in S_cd
        g = (rl[s,1] == 1 ? 1 : 2)
        pesDem = dp[s,g]
        volDem = dv[s,g]
        for v in V
              if (cp[v] < pesDem || cv[v] < volDem || (g == 2 && rv[v,2] == 0))
                    tipo[s,v] = 0
              end
            end
      end
  return tipo
end

#Função para converter o volume/peso da demanda para o volume/peso considerando que ela será entregue em rolls
function converteRoll(dp, dv, S)
    for s in S
        vol = dv[s,1]
        nRow = cld(vol, 0.901*0.8)
        dv[s,2] = nRow*1.12
        dp[s,2] = dp[s,1] + nRow*50
    end 
    return dp, dv
end

#Heuristicas para evitar o compartilhamento de certas lojas, de forma a acelerar o modelo
function makeHeuA(S_cd, td, dv, dp, rl, tf, ti, te)
    heu = 0
    listHeu = []
    for s in S_cd
          for l in S_cd
                if (td[s,l] > 3 || (dv[s] + dv[l] > 60) || (dp[s] + dp[l] > 7000) || rl[s] != rl[l] || ti[l] - tf[s] > 3 || tf[l] < ti[s] || s == l || tf[s]+te[s]+td[s,l] > tf[l])
                     push!(listHeu, [s, l])
                      heu += 1
                end
          end
    end

    H = 1:heu   
    return listHeu, H
end

#Mesmo propósito da função anterior, mas com heuristicas menos agressivas
function makeHeuB(S_cd, rl)
    heu = 0
    listHeu = []
    for s in S_cd
          for l in S_cd
                if (rl[s] != rl[l])
                     push!(listHeu, [s, l])
                      heu += 1
                end
          end
    end

    H = 1:heu   
    return listHeu, H
end

function convertOnes(r)
      if r > 1
            return 1
      else
            return 0
      end
end