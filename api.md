## Для разработчиков

- Запрос для покупки у ваших юзеров:
  ```
  curl -X 'POST' \
  'https://api.yodao.io/api/v1/trades/signals/tweet/sol' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "api_key": "448a037c-0838-4003-892a-01935554ec1c",
  "trade": "buy",
  "token": "EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm"
  }'
  ```
  https://api.yodao.io/api#/Trades/TradeApiController_createTweetMarketOrder

  ## Для админа
  - таблица `ApiKey` содержит ключи доступа к апи (можно менять, добавлять новые)
  - в таблице `ApiKeyUser` мы прописываем `userId` из таблицы `Users` (полe: id) и `ApyKeyId` из таблицы `ApiKey` (полe: id) для разрешения покупки по апи интеграции
  - в таблице `UserTradeSettings` мы прописываем TRUE в поле `isAutoBuyAvailable` для показа у юзера в интерфейсе иконки с Твитер авто покупкой 
