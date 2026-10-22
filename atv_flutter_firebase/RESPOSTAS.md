# Respostas da Atividade

### 1. Como o Firebase identifica quem escreveu determinado comentário?
O Firebase Authentication atribui um identificador exclusivo (`uid`) para cada usuário autenticado (`FirebaseAuth.instance.currentUser.uid`). Ao persistir o comentário no Cloud Firestore, esse `uid` é salvo explicitamente no campo `uidUsuario` do documento, permitindo identificar com exatidão e segurança a autoria de cada registro.

### 2. Como relacionar um comentário a uma publicação específica?
Armazenando os comentários como uma subcoleção dentro do documento da publicação correspondente (na rota `/publicacoes/{postId}/comentarios`) e mantendo o identificador `postId` gravado dentro do próprio documento do comentário.

### 3. Por que utilizamos StreamBuilder para mostrar os comentários?
O Cloud Firestore disponibiliza um fluxo reativo em tempo real via método `.snapshots()`. O `StreamBuilder` se inscreve nessa `Stream` e reconstrói os widgets da interface de forma automática sempre que novos dados forem inseridos, modificados ou excluídos no banco, eliminando a necessidade de refresh manual.

### 4. Como garantir que os comentários apareçam automaticamente em contas diferentes?
Ambos os dispositivos/contas mantêm um `StreamBuilder` conectado ativamente à mesma subcoleção daquele post. Como o Firestore opera via conexões persistentes (WebSockets/gRPC), assim que um usuário envia um novo comentário, o servidor propaga o snapshot com a atualização instantaneamente para todos os clientes conectados.
