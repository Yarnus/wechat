defmodule WeChat.Account do
  @moduledoc "账号管理"
  import Jason.Helpers
  import WeChat.Utils, only: [doc_link_prefix: 0]
  alias WeChat.Requester

  @typedoc """
  二维码类型
    * `"QR_SCENE"`            为临时的整型参数值
    * `"QR_STR_SCENE"`        为临时的字符串参数值
    * `"QR_LIMIT_SCENE"`      为永久的整型参数值
    * `"QR_LIMIT_STR_SCENE"`  为永久的字符串参数值
  """
  @type qrcode_action_name :: String.t()

  @doc """
  获取AccessToken - [Official API Docs Link](#{doc_link_prefix()}/doc/offiaccount/Basic_Information/Get_access_token.html){:target="_blank"}
  """
  @spec get_access_token(WeChat.client()) :: WeChat.response()
  def get_access_token(client) do
    Requester.get("/cgi-bin/token",
      query: [
        grant_type: "client_credential",
        appid: client.appid(),
        secret: client.appsecret()
      ]
    )
  end

  @doc """
  生成二维码 - [Official API Docs Link](#{doc_link_prefix()}/doc/offiaccount/Account_Management/Generating_a_Parametric_QR_Code.html){:target="_blank"}
  """
  @spec create_qrcode(
          WeChat.client(),
          scene_id :: String.t(),
          qrcode_action_name,
          expire_seconds :: integer
        ) :: WeChat.response()
  def create_qrcode(client, scene_id, action_name \\ "QR_LIMIT_SCENE", expire_seconds \\ 1800)
      when action_name in [
             "QR_SCENE",
             "QR_STR_SCENE",
             "QR_LIMIT_SCENE",
             "QR_LIMIT_STR_SCENE"
           ] do
    scene_key = (action_name in ["QR_STR_SCENE", "QR_LIMIT_STR_SCENE"] && :scene_str) || :scene_id

    Requester.get(
      "/cgi-bin/qrcode/create",
      json_map(
        action_name: action_name,
        expire_seconds: expire_seconds,
        action_info: %{
          scene: %{
            scene_key => scene_id
          }
        }
      ),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  长链接转成短链接 - [Official API Docs Link](#{doc_link_prefix()}/doc/offiaccount/Account_Management/URL_Shortener.html){:target="_blank"}
  """
  @spec short_url(WeChat.client(), long_url :: String.t()) :: WeChat.response()
  def short_url(client, long_url) do
    Requester.get(
      "/cgi-bin/shorturl",
      json_map(
        action: "long2short",
        long_url: long_url
      ),
      query: [access_token: client.get_access_token()]
    )
  end

  @doc """
  接口调用次数清零 - [Official API Docs Link](#{doc_link_prefix()}/doc/oplatform/Third-party_Platforms/Official_Accounts/Official_account_interface.html){:target="_blank"}
  """
  @spec clear_quota(WeChat.client()) :: WeChat.response()
  def clear_quota(client) do
    Requester.post("/cgi-bin/clear_quota", json_map(appid: client.appid()),
      query: [access_token: client.get_access_token()]
    )
  end
end