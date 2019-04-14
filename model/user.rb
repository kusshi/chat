require 'mongoid'
require 'bcrypt'

class User
    include Mongoid::Document

    # fieldを設定
    field :name
    field :email
    field :password_hash
    field :password_salt

    # attr_readonlyはActiveRecord::Base
    attr_readonly :password_hash, :password_salt

    # fieldのvalidateを追加
    validates :name, presence: true
    validates :name, uniqueness: true
    # validates :email, uniqueness: true
    # validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create }
    # validates :email, presence: true
    validates :password_hash, confirmation: true
    validates :password_hash, presence: true
    validates :password_salt, presence: true

    # パスワード暗号化用のメソッド
    def encrypt_password(password)
        if password.present? then
            self.password_salt = BCrypt::Engine.generate_salt
            self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
        end
    end

    # ユーザ認証用メソッド
    def self.authenticate(name, password)
        user = self.where(name: name).first
        if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt) then
            user # 一致するときのみuserを返す
        else
            nil
        end
    end

end
