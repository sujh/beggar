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
    Sidekiq::Cron::Job.find(job_name(@beggar))&.destroy
    redirect_to beggars_url
  end

  def run
    if check_beggar_ok?
      Sidekiq::Cron::Job.new(name: job_name(@beggar), cron: "*/2 * * * *", class: "BegWorker", args: [@beggar.id]).save
      @beggar.update(status: :running)
      @alert = {type: "success", title: "成功", body: "代理源配置检测无异常，加入执行队列"}
    else
      @alert = {type: "danger", title: "错误", body: "代理源配置错误，尝试运行失败"}
    end
    render partial: "shared/alert"
  end

  def stop
    Sidekiq::Cron::Job.find(job_name(@beggar))&.destroy
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

  def job_name(beggar)
    "BegWorker:#{beggar.id}"
  end
end
