class BeggarsController < ApplicationController
  before_action :load_beggar, only: [:edit, :update, :destroy, :run, :stop]
  def index
    @beggars = Beggar.all
    render :index
  end

  def new
    @beggar = Beggar.new
    render partial: "form"
  end

  def create
    Beggar.create(beggar_params)
    redirect_to beggars_url
  end

  def edit
    render partial: "form"
  end

  def update
    @beggar.update(beggar_params)
    redirect_to beggars_url
  end

  def destroy
    @beggar.destroy
    redirect_to beggars_url
  end

  def run
  end

  def stop
  end

  private

  def beggar_params
    params.require(:beggar).permit(:name, :site, :parser)
  end

  def load_beggar
    @beggar = Beggar.find(params[:id])
  end
end
