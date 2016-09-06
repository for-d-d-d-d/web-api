class DeviseCreateUsers < ActiveRecord::Migration
    def change
        create_table :users do |t|
            ## Added attribut
            ## 회원 정보 머필요??
            ## 이메일, 패스워드, 이름, 성별, 생년월일(나이)
            t.string :name,               null: false, default: ""
            # t.string :birthdate,          null: false, default: ""
            t.integer :gender,             null: false, default: 0 # 0:기본, 1:남, 2:여, 3:표기거절
            
            ## for omniauth
            t.string :provider
            t.string :uid

            ## Database authenticatable
            t.string :email,              null: false, default: ""
            t.string :encrypted_password, null: false, default: ""
            t.string :mytoken              #null: false, default: ""

            ## Recoverable
            t.string   :reset_password_token
            t.datetime :reset_password_sent_at

            ## Rememberable
            t.datetime :remember_created_at

            ## Trackable
            t.integer  :sign_in_count, default: 0, null: false
            t.datetime :current_sign_in_at
            t.datetime :last_sign_in_at
            t.string   :current_sign_in_ip
            t.string   :last_sign_in_ip

            ## Confirmable
            # t.string   :confirmation_token
            # t.datetime :confirmed_at
            # t.datetime :confirmation_sent_at
            # t.string   :unconfirmed_email # Only if using reconfirmable

            ## Lockable
            # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
            # t.string   :unlock_token # Only if unlock strategy is :email or :both
            # t.datetime :locked_at


            t.timestamps null: false
        end

        add_index :users, :email,                unique: true
        add_index :users, :reset_password_token, unique: true
        # add_index :users, :confirmation_token,   unique: true
        # add_index :users, :unlock_token,         unique: true
    end
end
