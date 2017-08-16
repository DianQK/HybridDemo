import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import {
  BrowserRouter as Router,
  Route,
  Link
} from 'react-router-dom'
import Hybrid from './Hybrid'
import Hello from './Hello'

class HybridRoute extends Route {

  render() {
    if (this.state.match) {
      // window.$native.title = this.props.title || ''
      window.$native.title = ''
      window.$native.rightBarTitle = ''
    }
    return super.render()
  }

}

class App extends Component {
  render() {
    return (
      <div className="App">
        <div className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h2>Welcome to React</h2>
        </div>
        <Router>
          <div>
            <ul>
              <li><Link to="/hybrid">Hybrid</Link></li>
              <li><Link to="/hello">Hello</Link></li>
            </ul>

            <HybridRoute path="/hybrid" component={Hybrid} title="Hybrid" />
            <HybridRoute path="/hello" component={Hello} title="Hello" />
          </div>
        </Router>
      </div>
    );
  }
}

export default App;
