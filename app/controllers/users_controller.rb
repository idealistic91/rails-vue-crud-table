class UsersController < ApplicationController
    def index
        @crud_table = ::VueCrudTable::Base.new
        @users = User.all.paginate(page: params[:page], per_page: params[:per_page])
        render json: { data: @users, headers: @crud_table.headers, pages: @users.total_pages, count: @users.total_entries }
    end

    def show
      @user = User.find(params[:id])
      render json: { data: @user, status: :ok, message: 'Success' }
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        render json: { status: :ok, message: 'Success' }
      else
        render json: { json: @user.errors, status: :unprocessable_entity }
      end
    end

    def create
      @user = User.new(user_params)
      if @user.save
        render json: { status: :ok, message: 'Success' }
      else
        render json: { json: @user.errors, status: :unprocessable_entity }
      end
    end

    def destroy
      @user = User.find(params[:id])
      if @user.destroy
        render json: { json: 'User was successfully deleted.'}
      else
        render json: { json: @user.errors, status: :unprocessable_entity }
      end
    end

    private
    
    def user_params
      params.require(:user).permit(:id, :first_name, :last_name, :email, :phone, :address)
    end
end
