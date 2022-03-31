## 概要
fjordbootcampの「WebアプリからのDB利用」の提出物です。

## 起動までの手順

1. 任意のディレクトリにこのリポジトリをクローンします。
```
git clone https://github.com/daiki0381/Sinatra_practice.git
```

2. リポジトリに移動します。
```
cd Sinatra_practice
```

3. PostgreSQLをインストールします。(既にPostgreSQLをインストール済の場合は不要です。)
```
brew install postgresql
```

4. データーベース「sinatra」を作成します。
```
createdb sinatra
```

5. 必要なGemをインストールします。
```
bundle install
```

6. アプリを起動します。
```
bundle exec ruby app.rb
```

7. `http://localhost:4567/memos`にアクセスします。
