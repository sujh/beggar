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
    if check_beggar_ok?
      job = Sidekiq::Cron::Job.new(name: "BegWorker:#{beggar.id}", cron: "0 * * * *", class: "BegWorker", args: [beggar.id])
      BegWorker.perform_async(@beggar.id)
      @beggar.update(status: :running)
      @alert = {type: "success", title: "成功", body: "代理源配置检测无异常，加入执行队列"}
    else
      @alert = {type: "danger", title: "错误", body: "代理源配置错误，尝试运行失败"}
    end
    render partial: "shared/alert"
  end

  def stop
    Sidekiq.cancel!(@beggar.jid)
    @beggar.update(status: :stopped)
    @alert = {type: "success", title: "成功", body: "从执行队列剔除"}
    render partial: "shared/alert"
  end

  private

  def beggar_params
    params.require(:beggar).permit(:name, :site, :parser)
  end

  def load_beggar
    @beggar = Beggar.find(params[:id])
  end

  def check_beggar_ok?
    # return true
    !!Proxy::BegService.new(@beggar).beg
  rescue
    false
  end
end
