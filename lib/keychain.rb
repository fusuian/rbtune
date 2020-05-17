# Pit のフロントエンド。
# key に uri を指定すると、accountでアカウントとパスワードのセットを得られる。
# key が空の場合、queryによってアカウントとパスワードのセットを登録できる。
# パスワードの難読化はごく甘く、単にBase64でエンコードしているのみ。

require "pit"
require "base64"
require 'io/console'

class KeyChain
  attr_reader :key

  def initialize(key)
    @key = key
  end


  def account
    radiko = Pit.get(key)
    if radiko.has_key? :account and radiko.has_key? :password
      [ radiko[:account], Base64.decode64(radiko[:password]) ]
    end
  end


  def set(account, password)
    Pit.set(key, data: { account: account, password: Base64.encode64(password)})
    [account, password]
  end


  def query(prompt, account)
    old_account, old_password = account()
    puts prompt
    print '  password : '
    STDOUT.flush
    new_password = STDIN.noecho(&:gets).chomp
    puts
    raise "空のパスワードは無効です (何も変更されません)" if new_password.empty?
    set account, new_password
  end
end