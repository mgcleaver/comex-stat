# comex-stat

# Visão geral

Este repositório automatiza o download de dados brutos da base Comex Stat e
organiza os dados em uma base no diretório database deste projeto ou,
alternativamente, em um diretório do OneDrive.
Apenas algumas variáveis da base do Comex Stat são selecionadas para 
montar a base: ano, mês, código ncm, país, valores em dólares FOB (para 
importações também temos valores em dólares CIF), peso em quilogramas líquidos
e quantidade estatística. Os nomes das colunas da base são os seguintes:

- co_ano (ano)
- co_mes (mês)
- co_ncm (código ncm)
- co_pais (país)
- vl_fob (valor em dólares fob)
- vl_cif (valor em dólares cif)
- kg_liquido (peso em quilogramas líquido)
- qt_estat (quantidade estatística)
