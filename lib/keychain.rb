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


  def query(prompt)
    old_account, old_password = account()
    puts prompt
    print "  account (#{old_account}) > "
    STDOUT.flush
    new_account = gets.chomp
    new_account = old_account if new_account.empty?
    print '  password> '
    STDOUT.flush
    new_password = STDIN.noecho(&:gets).chomp
    puts
    raise "空のパスワードは無効です" if new_password.empty?
    set new_account, new_password
  end
end