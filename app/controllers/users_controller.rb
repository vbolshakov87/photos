class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(post_params)
    if @user.save
      redirect_to root_url, :notice => 'Signed Up!'
    else
      render 'new'
    end
  end


  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      postParams = params.require(:user).permit(:email, :password, :password_confirmation)
      return postParams
    end

end
