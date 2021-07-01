class BeggarsController < ApplicationController
	def index
		@beggars = Beggar.all
		render :index
	end

	def new
		@beggar = Beggar.new
		logger.info("!")
		render partial: "form"
	end

	def create
		Beggar.create(beggar_params)
		redirect_to beggars_url
	end

	def edit
		@beggar = Beggar.find(params[:id])
		render partial: "form"
	end

	def update
		@beggar = Beggar.find(params[:id])
		@beggar.update(beggar_params)
		redirect_to beggars_url
	end

	def destroy
		Beggar.find(params[:id]).destroy
		redirect_to beggars_url
	end

	private

		def beggar_params
			params.require(:beggar).permit(:name, :site, :parser)
		end

end
