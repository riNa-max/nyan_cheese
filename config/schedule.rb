# Rails.rootを使用するために必要
require File.expand_path(File.dirname(__FILE__) + '/environment')

# cronを実行する環境変数
rails_env = ENV['RAILS_ENV'] || :development

# cronを実行する環境変数をセット
set :environment, rails_env

# cronのログの吐き出し場所
set :output, "#{Rails.root}/log/cron.log"

# ログインシェルとして実行
set :job_template, "/bin/bash -l -c ':job'"

# rbenvのパスを通す
#job_type :rake, <<~CMD
#  cd :path && \
#  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH" && \
#  if command -v rbenv >/dev/null 2>&1; then
#    eval "$(rbenv init -)";
#  fi && \
#  bundle exec rake :task --silent :output
#CMD

job_type :rake, <<~CMD
  cd :path && \
  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH" && \
  if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)";
  fi && \
  rake :task :output
CMD

#定期実行したい処理を記入
every 3.days do
  rake "remind:send"
end
