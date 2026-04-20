package com.hr.datacenter.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hr.datacenter.entity.Message;
import com.hr.datacenter.mapper.mysql.MessageMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 消息服务
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@Service
public class MessageService extends ServiceImpl<MessageMapper, Message> {

    /**
     * 保存消息
     */
    public boolean saveMessage(Message message) {
        return this.save(message);
    }

    /**
     * 获取用户消息列表
     */
    public List<Message> getMessageList(Long userId, int page, int size) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getReceiverId, userId)
                .orderByDesc(Message::getCreateTime);

        int offset = (page - 1) * size;
        return this.list(wrapper);
    }

    /**
     * 获取未读消息数量
     */
    public int getUnreadCount(Long userId) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getReceiverId, userId)
                .eq(Message::getIsRead, 0);
        return (int) this.count(wrapper);
    }

    /**
     * 标记消息为已读
     */
    public boolean markAsRead(Long messageId) {
        Message message = this.getById(messageId);
        if (message != null) {
            message.setIsRead(1);
            return this.updateById(message);
        }
        return false;
    }

    /**
     * 批量标记为已读
     */
    public boolean markAllAsRead(Long userId) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getReceiverId, userId)
                .eq(Message::getIsRead, 0);

        List<Message> messages = this.list(wrapper);
        for (Message message : messages) {
            message.setIsRead(1);
        }

        return this.updateBatchById(messages);
    }

    /**
     * 删除消息
     */
    public boolean deleteMessage(Long messageId) {
        return this.removeById(messageId);
    }
}
