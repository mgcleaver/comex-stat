# comex-stat

## Visão geral

Este repositório automatiza o download de dados brutos da base Comex Stat e organiza os dados em uma base no diretório **database** deste projeto ou, alternativamente, em um diretório do OneDrive. Apenas algumas variáveis da base do Comex Stat são selecionadas para montar a base: ano, mês, código NCM, país, valores em dólares FOB (para importações também temos valores em dólares CIF), peso em quilogramas líquidos e quantidade estatística. Os nomes das colunas da base são os seguintes:

-   co_ano (ano)
-   co_mes (mês)
-   co_ncm (código NCM)
-   no_pais (nome do país)
-   vl_fob (valor em dólares fob)
-   vl_cif (valor em dólares cif)
-   kg_liquido (peso em quilogramas líquido)
-   qt_estat (quantidade estatística)

Para facilitar as consultas, optou-se por trazer na base o nome do país, em vez de trazer o código do país.

## Criação da base do Comex Stat na pasta database (local)

Esta é a opção mais simples e gera os dados na pasta database.

Para gerar a base a partir do ano de 2015, você pode executar no console do R:

```         
source("scripts/comexstat.R", encoding = "UTF-8")
```

Caso deseje obter dados anteriores a 2015, basta alterar o objeto `ano_inicial` do arquivo **scripts/comexstat.R** para o ano desejado.

## Criação da base do Comex Stat no OneDrive - Windows

Esta solução pode fazer mais sentido se você trabalha com uma equipe e centraliza os dados no OneDrive. Primeiramente é preciso entrar no OneDrive da sua equipe via browser. Após acessar qualquer um dos serviços, vá em Documentos e selecione um diretório (pasta) para alocar os dados do Comex Stat. Por exemplo, você pode criar um diretório com o nome **Documentos/General/Bases/comexstat**.

Na pasta comexstat ou a que você tiver escolhido, crie mais duas pastas. Uma chamada **export** e outra chamada **import**.

Caso a pasta do OneDrive da sua equipe não esteja sincronizada no seu computador, vai ser necessário fazer uma sincronização. Cada um dos membros da equipe deverá fazer isso se quiser acessar os dados da base do Comex Stat. No browser, escolha a pasta que você deseja sincronizar. Se fizer sentido para você, pode sincronizar a pasta **General** ou equivalente. Caso só faça sentido sincronizar a pasta **Bases**, navegue via browser até ela. Todas as subpastas dentro da pasta selecionada e seus arquivos serão sincronizadas no seu computador, a menos que você exclua alguma pasta da sincronização.

Uma vez que você esteja visualizando no browser as pastas e arquivos da pasta que você quer sincronizar, na barra de opções, clique em **Sincronizar**:

![](img/barra_onedrive.jpg)

Isso iniciará a configuração da pasta no seu Explorador de Arquivos.

Agora abra o arquivo **.Renviron** que fica no seu diretório de trabalho. Caso não tenha esse arquivo, crie-o e deixe-o aberto no editor de código.

Abra o explorador e verifique se você encontra, na barra lateral esquerda de acesso às pastas, a pasta raiz do OneDrive empresarial. Assim que encontrar, abra o OneDrive empresarial a partir do Explorador de Arquivos e navegue até a pasta **export**. Clique na barra de endereço do Explorador de Arquivos e copie o diretório completo que ali consta. O diretório deve ser parecido com:

`C:\caminho\para\sua\pasta\onedrive\Bases\comexstat\export`

No seu arquivo **.Renviron,** aberto no editor de código, cole a informação copiada após o `export=` e substitua as contrabarras por barras:

```         
export=C:/caminho/para/sua/pasta/onedrive/Bases/comexstat/export
```

Agora faça a mesma coisa com a pasta import. Seu arquivo **.Renviron** deve conter as seguintes linhas (ou os dirétorios definidos para cada base):

```         
export=C:/caminho/para/sua/pasta/onedrive/Bases/comexstat/export
import=C:/caminho/para/sua/pasta/onedrive/Bases/comexstat/import
```

Salve o arquivo **.Renviron** e reinicie sua sessão do R. Para verificar que a configuração de variáveis de ambiente deu certo, no console do R, digite `Sys.getenv("export")` e observe se aparece o caminho definido na variável no output. Da mesma forma, teste `Sys.getenv("import")` e observe se aparece o caminho definido. No caso de aparecer um "", alguma coisa não funcionou corretamente na configuração.

Caso o seu arquivo .Renviron e seu OneDrive configurados corretamente, você pode executar no console do R:

```         
source("scripts/comexstat_onedrive.R", encoding = "UTF-8")
```

Isso irá gerar a base no OneDrive.

## Lendo os dados da base

Após a escrita dos dados, para acessar a base você pode usar as principais funções do `dplyr` normalmente,
seguidas de `collect.

```
library(arrow)
library(dplyr)

# para ler os dados da base de exportação local
dados_exp <- open_dataset("dataset/export") %>% 
  group_by(co_ano) %>% 
  summarise(vl_fob = sum(vl_fob)) %>% 
  ungroup() %>% 
  collect()
  
# alternativamente, caso os dados estejam configurados no OneDrive
dados_exp <- open_dataset(Sys.getenv("export")) %>% 
  group_by(co_ano) %>% 
  summarise(vl_fob = sum(vl_fob)) %>% 
  ungroup() %>% 
  collect()
  
# também pode ler dados de importação
dados_imp <- open_dataset(Sys.getenv("import")) %>% 
  filter(co_ano == 2024) %>%
  group_by(co_ano, co_mes) %>% 
  summarise(vl_fob = sum(vl_fob)) %>% 
  ungroup() %>% 
  collect()
  
```