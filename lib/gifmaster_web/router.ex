defmodule GifmasterWeb.Router do
  use GifmasterWeb, :router

  import GifmasterWeb.Plugs
  import GifmasterWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GifmasterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :assign_url_helpers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GifmasterWeb do
    pipe_through :browser

    live_session :public_routes, on_mount: [{GifmasterWeb.UserAuth, :mount_current_user}, {GifmasterWeb.Hooks, :global}] do
      live "/", HomeLive
      live "/upload/new", HomeLive, :upload
      live "/upload/:gif_id", HomeLive, :upload
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", GifmasterWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gifmaster, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GifmasterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", GifmasterWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{GifmasterWeb.UserAuth, :redirect_if_user_is_authenticated}, {GifmasterWeb.Hooks, :global}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", GifmasterWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{GifmasterWeb.UserAuth, :ensure_authenticated}, {GifmasterWeb.Hooks, :global}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", GifmasterWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{GifmasterWeb.UserAuth, :mount_current_user}, {GifmasterWeb.Hooks, :global}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
