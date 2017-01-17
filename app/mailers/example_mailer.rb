class ExampleMailer < ApplicationMailer
    
    default from: "master@slubby.net"

    def sample_email(user)
            
        @user = user
        @user.password = SecureRandom.hex(3)
        @user.save
        mail(to: @user.email, subject: 'Reset Password')
        
    end
    
end
