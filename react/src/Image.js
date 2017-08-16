import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class Image extends Component {

  constructor(props) {
    super(props);
    this.state = {
      show: true
    }
  }

  // shouldComponentUpdate(nextProps) {
  //   return nextProps.title !== this.props.title
  // }

  componentWillMount () {
    window.$native.rightBarClick = () => {
      this.props.onClick()
    }
  }

  componentWillUnmount () {
    // window.$native.rightBarClick = null
  }

  displayImage = async () => {
    if (!this.props.fullScreen) {
      return
    }
    let width = this.image.width
    let height = this.image.height
    let x = this.image.offsetLeft
    let y = this.image.offsetTop
    this.setState({
      show: false
    })
    await window.$native.event('displayImage', { x, y, width, height, image: this.props.src })
    this.setState({
      show: true
    })
  }

  render () {
    return (this.state.show ? <img src={this.props.src} width="200" onClick={this.displayImage} ref={(img) => { this.image = img }} alt=""/> : null)
  }
}

Image.propTypes = {
  src: PropTypes.string,
  fullScreen: PropTypes.boolean
};
