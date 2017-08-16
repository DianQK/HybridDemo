import React, { Component } from 'react';
import './App.css';
import NativeTitle from './NativeTitle'

export default class extends Component {

  constructor(props) {
    super(props);
    this.state = {
      title: 'Hybrid Page'
    }
  }

  handleChange = (event) => {
    this.setState({ title: event.target.value })
  }

  render () {
    return (
      <div className="App">
      <NativeTitle title={this.state.title} />
      Hybrid
      <input value={this.state.title} onChange={this.handleChange} />
      </div>
    );
  }

}
