defmodule WeChatTest do
  use ExUnit.Case
  alias WeChat.Utils
  alias WeChat.ServerMessage.{EventHandler, XmlMessage, XmlParser}
  doctest WeChat

  test "Auto generate functions" do
    assert WxApp.app_type() == :official_account
    assert WxApp.by_component?() == false
    assert WxApp.server_role() == :client
    assert WxApp.code_name() == "wxapp"
    assert WxApp.storage() == WeChat.Storage.File
    assert WxApp.appid() == "wx2c2769f8efd9abc2"
    assert WxApp.appsecret() == "appsecret"
    assert WxApp.encoding_aes_key() == "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG"

    aes_key =
      WeChat.ServerMessage.Encryptor.aes_key("abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG")

    assert WxApp.aes_key() == aes_key
    assert WxApp.token() == "spamtest"
    assert true = Enum.all?(1..3, &function_exported?(WxApp, :get, &1))
    assert true = Enum.all?(2..4, &function_exported?(WxApp, :post, &1))
  end

  test "Auto generate functions(Work)" do
    assert WxWork.app_type() == :work
    assert WxWork.by_component?() == false
    assert WxWork.server_role() == :client
    assert WxWork.storage() == WeChat.Storage.File
    assert WxWork.appid() == "corp_id"
    assert is_list(WxWork.agents())
    assert WxWork.agent2cache_id(10000) == "corp_id_10000"
    assert WxWork.agent2cache_id(:agent_name) == "corp_id_10000"

    assert true = Enum.all?(1..3, &function_exported?(WxApp, :get, &1))
    assert true = Enum.all?(2..4, &function_exported?(WxApp, :post, &1))
  end

  test "build official_account client" do
    opts = [
      appid: "wx2c2769f8efd9abc2",
      appsecret: "appsecret",
      encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG",
      token: "spamtest"
    ]

    assert {:ok, WxApp3} = WeChat.build_client(WxApp3, opts)
    assert apply(WxApp3, :appid, []) == "wx2c2769f8efd9abc2"
    assert function_exported?(WxApp3.WebPage, :code2access_token, 1)
    assert false == function_exported?(WxApp3.MiniProgram.Auth, :code2session, 1)
  end

  test "build component client" do
    opts = [
      appid: "wx2c2769f8efd9abc2",
      by_component?: true,
      component_appid: "wx3c2769f8efd9abc3",
      appsecret: "appsecret",
      encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG",
      token: "spamtest"
    ]

    assert {:ok, WxApp4} = WeChat.build_client(WxApp4, opts)
    assert apply(WxApp4, :appid, []) == "wx2c2769f8efd9abc2"
    assert function_exported?(WxApp4.Component, :get_authorizer_info, 0)
    assert function_exported?(WxApp4.WebPage, :code2access_token, 1)
    assert false == function_exported?(WxApp4.MiniProgram.Auth, :code2session, 1)
  end

  test "build mini_program client" do
    opts = [
      app_type: :mini_program,
      appid: "wx2c2769f8efd9abc2",
      appsecret: "appsecret",
      encoding_aes_key: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFG",
      token: "spamtest"
    ]

    assert {:ok, WxApp5} = WeChat.build_client(WxApp5, opts)
    assert apply(WxApp5, :appid, []) == "wx2c2769f8efd9abc2"
    assert false == function_exported?(WxApp5.WebPage, :code2access_token, 1)
    assert function_exported?(WxApp5.MiniProgram.Auth, :code2session, 1)
  end

  test "xml_parse" do
    timestamp = Utils.now_unix()

    {:ok, map} =
      XmlMessage.reply_text(
        "oia2TjjewbmiOUlr6X-1crbLOvLw",
        "gh_7f083739789a",
        timestamp,
        "hello world"
      )
      |> XmlParser.parse()

    assert map == %{
             "Content" => "hello world",
             "CreateTime" => to_string(timestamp),
             "FromUserName" => "gh_7f083739789a",
             "MsgType" => "text",
             "ToUserName" => "oia2TjjewbmiOUlr6X-1crbLOvLw"
           }
  end

  test "Encrypt Msg" do
    timestamp = Utils.now_unix()

    xml_string =
      XmlMessage.reply_text(
        "oia2TjjewbmiOUlr6X-1crbLOvLw",
        "gh_7f083739789a",
        timestamp,
        "hello world"
      )
      |> EventHandler.encode_xml_msg(timestamp, WxApp)

    assert is_binary(xml_string) == true
  end
end
