
# CONFIGURAÇÃO - PADRÃO

SITE: [https://stackedit.io/app#](https://stackedit.io/app#)

## Backend

1. **Fazer Enum** (se necessário)
2. **Criar Modelo**
3. **Fazer a Migration**
    1. Comandos para gerenciamento de migrations:

    ```bash
    npx sequelize-cli migration:generate --name xx-xx # Gera um arquivo de migration 
    npx sequelize-cli db:migrate # Realiza todas migrations que não foram feitas 
    npx sequelize-cli db:migrate:undo # Desfaz a última migration 
    npx sequelize-cli db:migrate:undo:all # Desfaz todas migrations 
    npx sequelize-cli db:migrate:undo:all --to XXXXXXXXXXXXXX-create-posts.js # Desfaz todas migrations até a específica 
    ```

4. **Fazer o Seeder** (se necessário)
    1. Comandos para gerenciamento de seeds:

    ```bash
    npx sequelize-cli seed:generate --name xx-xx #Gera um arquivo de seed
    npx sequelize-cli db:seed --seed my-seeder-file.js #Executa um seed específico
    npx sequelize-cli db:seed:all #Executa todos os seeds
    npx sequelize-cli db:seed:undo #Desfaz o último seed
    npx sequelize-cli db:seed:undo --seed name-of-seed-as-in-data #Desfaz um seed específico
    npx sequelize-cli db:seed:undo:all #Desfaz todos os seeds
    ```

5. **Fazer o Controller**
6. **Fazer os Routers**
7. **Integrar ao Server.js**
    - Adicionar uma linha: `app.use(routes)`

## Frontend

1. **Fazer o Model**
2. **Fazer o Service**
3. **Fazer o Controller**
4. **Integrar na View/Page**
