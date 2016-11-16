class ChannelsController < ApplicationController
  def index
    @channels = cronofy.list_channels
  end

  def new
    unless ENV['DOMAIN']
      render :domain_not_set and return
    end

    @channel = Channel.new

    @calendars = cronofy.list_calendars
    @channel.calendar_ids = @calendars.map { |calendar| calendar.calendar_id }
  end

  def create
    @channel = Channel.new(params[:channel].permit!)

    @channel.calendar_ids = @channel.calendar_ids.reject { |c_id| c_id.empty? }

    unless @channel.valid?
      @calendars = cronofy.list_calendars

      render :new and return
    end

    channel = cronofy.create_channel(@channel)

    @channel.channel_id = channel.channel_id
    @channel.save

    redirect_to channels_path
  end

  def show
    @channel = cronofy.list_channels.find { |channel| channel.channel_id == params[:id] }

    channel = Channel.find { |channel| channel.channel_id == params[:id] }
    @channel.last_body = channel.last_body
    @channel.last_called = channel.last_called
  end
end