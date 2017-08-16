import React, { Component } from 'react'
import './App.css'
import NativeTitle from './NativeTitle'
import NativeRightBar from './NativeRightBar'
import Image from './Image'

export default class extends Component {

  constructor(props) {
    super(props);
    this.state = {
      count: 0,
      selectedImage: 'https://facebook.github.io/react/img/logo.svg',
      rightBarTitle: 'Chat',
    }
  }

  handleClick = () => {
    this.setState((prevState) => ({
      count: prevState.count + 1
    }))
  }

  selectImage = async () => {
    let response = await window.$native.event('selectImage')
    this.setState({
      selectedImage: response.image
    })
  }

  changeRightBarTitle = (title) => {
    this.setState({
      rightBarTitle: title
    })
  }

  render() {
    return (
      <div className="App">
      <NativeTitle title="Hello" />
      <NativeRightBar title={this.state.rightBarTitle} onClick={this.handleClick}/>
      <ul>
        <li><a onClick={this.selectImage}>选择图片</a></li>
        <li><a onClick={() => this.changeRightBarTitle('Forum')}>Forum</a></li>
        <li><a onClick={() => this.changeRightBarTitle('Chat')}>Chat</a></li>
      </ul>
      {this.state.count}
      <div>
      <Image src={this.state.selectedImage} width="200" fullScreen />
      </div>
      </div>
    );
  }
}
