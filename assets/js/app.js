// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import 'bootstrap';
import css from "../css/app.scss";
import Header from './header';
import Slider from './slider';
import GoogleMap from './map';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

// assets/js/app.js
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

var token_content = null;

let csrfToken = document.querySelector("meta[name='csrf-token']");
if (csrfToken != null) {
  token_content = csrfToken.getAttribute("content");
} else { }
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: token_content}})
liveSocket.connect()

Header.run();
Slider.run();
GoogleMap.run();
